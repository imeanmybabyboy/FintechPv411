// SPDX-License-Identifier: UNLICENSED
// усі смарт-контракти повинні починатися з ліцензії, що регулює авторське право на його код

pragma solidity ^0.8.28;
// обов'язково зазначити обмеження на версію компілятора

contract Counter { // Контракт - аналог класу ООП 
  uint public x; // поле типу uint - типізація статична

  event Increment(int8 by); // Події - засіб інформування про зміни у смарт контракті
                            // int/uint змінюються від int8...int256
                            // aliases int - int256, uint - uint256

  function inc() public {
    x += 1; // зміна стану - немає інформування
    emit Increment(1); // запуск події - інформування
  }

  function incBy(int8 by) public {
    require(by > 0, "incBy: increment should be positive");
    x += uint8(by);
    emit Increment(by);
  }

  function dec() public {
    require(x - 1 >= 0, "dec: decrement result should be non-negative");
    x -= 1;
    emit Increment(-1);
  }

  function decBy(int8 by) public {
    require(by > 0, "incBy: increment should be positive");
    require(int(x) - by >= 0, "decBy: decrement result should be non-negative");
    x -= uint8(by);
    emit Increment(-by);
  }

  // view - означає, що функція не вносить змін до контексту (стану)
  // виклик таких функцій значно дешевший (або безкоштовний)
  // тип повернення також має зазначатись оператором returns
  function getCount() public view returns(uint) {
    return x; // Solidity розрізняє звернення "x" та "this.x"
              // "x" - звернення до змінної (стану)
              // "this.x" - неявний виклик гетера
  }

  
}
