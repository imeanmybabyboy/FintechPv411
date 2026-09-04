// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "hardhat/console.sol";

contract Greeter {
    string private greeting;
    address private owner;   // address - число, що визначає вузол у мережі
    event Changed(string newGreeting);
    bytes4 constant InvalidID = 0xffffffff; // ERC-165 invalid id
    bytes4 constant ERC165ID = 0x01ffc9a7;  // ERC-165 valid id

    constructor(string memory initialGreeting) {
        greeting = initialGreeting;
        owner = msg.sender;
        // в методи передається спеціальний об'єкт msg, у якому збираються
        // дані про підключення до смарт-контракту
        console.log("Constructed contract with '", greeting, "' from ", owner);
    }

    receive() external payable {} // метод для дефолтного прийому ETH

    fallback() external payable { // обробник помилок неіснуючого методу (селектору) за замовчуванням
        // При виклику методу (селектору), якого не існує в смарт-контракті передаються відомості про його назву, але не в прямому вигляді, у полі msg.data закладаються перші 4 байти від хешу (keccak256) від імені (назви) метода (точніше, виклику - з урахуванням дужок) 
        console.log("Unknown selector from %s", msg.sender);
        if (msg.data.length >= 4) {
            // відокремлюємо перші 4 байти, для константних масивів-параметрів слайси дозволені
            bytes4 selectorHash = bytes4( msg.data[:4] );
            // не всі типи даних консоль виводить через базовий метод .log
            console.log("Selector hash starts with:");
            console.logBytes4(selectorHash);
        }
        else {
            console.log("No data about selector");
        }
    }

    // За стандартами ERC-20
    function decimals() public pure returns (uint8) {
        return 8;
    }

    function symbol() public pure returns (string memory) {
        return "ABC";
    }

    function balanceOf(address _owner) public pure returns (uint256 balance) {
        if (_owner != address(0)) {
            return 100;
        }
    }

    // За стандартами ERC-165 0x01ffc9a7
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        if(interfaceId[0] != ERC165ID[0]) return false;
        if(interfaceId[1] != ERC165ID[1]) return false;
        if(interfaceId[2] != ERC165ID[2]) return false;
        if(interfaceId[3] != ERC165ID[3]) return false;
        return true;
    }

    function greet() public view returns (string memory) {
        return string.concat(greeting, " by ", addressToString(owner));
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
        emit Changed(greeting);
    }

    // адреси подаються у гексадецимальному представленні 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
    // але автоматично воно не формується, необхідно створювати додаткові методи
    function addressToString(address _address) internal pure returns (string memory) {
        // Solidity закладає декілька типів, що відповідають за масиви
        // фіксованої довжини, зокрема, bytes32 -- byte[32]
        bytes32 _bytes = bytes32(uint256(uint160(_address)));
        bytes memory HEX = "0123456789abcdef";   // ref-тип, слід зазначити сховище
        bytes memory _res = new bytes(42);       // 0,x,40 цифр (160 біт)
        bytes memory _addr = new bytes(40);      // адреса, але без 0x
        _res[0] = '0';
        _res[1] = 'x';
        for(uint i = 0; i < 20; i++) {
            _addr[i * 2] = _res[2 + i * 2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[1 + i * 2] = _res[3 + i * 2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        // внутрішній механізм контролю адрес:
        // оскільки на значення байту не впливає розмір літери (0x1A == 0x1A)
        // є можливість змінювати регістр літер за певним алгоритмом, що дозволить відокремлювати неправильно сформовані адреси, а також ускаднить їх перебір через необхідність додатакової обробки
        // Ідея - обчислення хечу keccak256 від адреси, що сформована у нижньому регістрі (без 0х) і подальший контроль символів хешу - якщо їх значення 8 і більше, то літера переводиться до верхнього регістру (з таблиці ASCII для літер різного регістру коди відрізняються на 32)
        bytes32 _k = keccak256(abi.encodePacked(string(_addr)));
        for (uint i = 0; i < 20; i++) {
            uint8 _x = uint8(_k[i] >> 4);
            if (_x >= 8 && _res[2 + 2 * i] > '9') { // потрібно перевести до верхнього регістру літеру адреси
                _res[2 + 2 * i] = bytes1( uint8(_res[2 + 2 * i]) - 32 );
            }
            _x = uint8(_k[i] & 0x0f);
            if (_x >= 8 && _res[3 + 2 * i] > '9') { // потрібно перевести до верхнього регістру літеру адреси
                _res[3 + 2 * i] = bytes1( uint8(_res[3 + 2 * i]) - 32 );
            }
        }
        return string(_res);
    }
    /* Представити число (2 байти 0101101011000011) у гексадецимальному представленні
    0101 1010 1100 0011
      5    a    c    3
    _res[0] = '0';      _res
    _res[1] = 'x';      0x
    i=0
    _res[2] = ...'5'
      0101 1010 >> 1 -> 00101 101 >> 1 -> 000101 10 ...
      0101 1010 >> 4 -> 0000 0101 = 5
      HEX[5] = '5'
    _res[3] = ...'a'
      0101 1010 & 0x0f = 0101 1010
                         0000 1111 (0x0f)
                         -------------
                         0000 1010 - занулення першої половини байту
      HEX[10] = 'a'            
    i = 1
    _res[4 = 2 + 2*i]  HEX[1100 0011 >> 4 -> 0000 1100] -> 'c'       
    _res[5 = 3 + 2*i]  HEX[1100 0011 & 0x0f -> 0000 0011] -> '3'

Д.З. Скласти метод мовою Solidity, який з рядкового (string)
представлення адреси формує її байт-представлення (string-to-address)
- зворотню функцію до складеної на зустрічі

Д.З. Скласти метод мовою Solidity, який з числа робить його 
бінарне представлення у вигляді рядка на кшталт 0110010100101101
* поділити це представлення на групи по 8 біт: 01100101 00101101
    */
}
/*
Solidity передбачає декілька способів розміщення змінних, у т.ч. параметрів і полів
Storages:
 - storage - постійне сховище, що зберігає результати між запусками методів
 - transient storage - сховище, що зберігається протягом транзакції, потім видаляється
 - memory - зберігається протягом одного виклику.
Спосіб збереження впливає на вартість виконання функції

Побічна дія функцій (side effect) - зміна поза тілом функції за результатами її роботи
++ можливість "повернення" кількох значень, зокрема статусу
    int x = parseInt("123x") - відсутність можливості розрізнити неправильний вхід
    ---
    int x;
    bool tryParseInt(string, &int)
    if( tryParseInt("123x", &x) ) { ... в х - гарантовано правильне значення}
    else { помилка перетворення }
    ---
    int squareEquation(a,b,c,&x1,&x2)
-- неконтрольовані зміни, помилки з іменуванням (наявність глобальної змінної з даним іменем)
    int i;
    ...
    func() { for(i=0; i...)}
Рекомендація - "заявляти" про побічну дію в сигнатурі функції - вводити ref-параметри 

ООП ускладнює проблему через те, що методи формально мають право змінювати
стан об'єкту, хоча він належить області поза методами, тобто чинити побічну дію.
В такому разі, навпаки, помічають "чисті" функції, які не взаємодіють з 
станом об'єкту.
Плюс виділяють "view" методи, які не змінюють стан, але можуть його читати.
*/