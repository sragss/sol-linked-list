// SPDX-LICENSE-IDENTIFIER: GPL-3.0
pragma solidity ^0.8.8;


contract LinkedList {

    /**
     * Poor implementation of a linked list.
     * Goal is to store an ordered list of top 100 numbers sent by users.
     * Has numerous problems. Notably that duplicate numbers from the same user are not handled properly.
     */

    uint constant LIST_SIZE = 100;

    struct SenderWithNumber {
        bytes32 next;
        uint number;
        address sender;
    }

    // Pointer to lowest element in list
    bytes32 head;
    uint numInList = 0;
    mapping (bytes32 => SenderWithNumber) public items;

    // Init with first bid -- for ease, could just as well do a 0 check on insert
    constructor(uint _firstNumber) {
        bytes32 id = createId(msg.sender, _firstNumber);
        head = id;
        numInList = 1;
        SenderWithNumber memory item = SenderWithNumber(0x0, _firstNumber, msg.sender);
        items[id] = item;
    }

    function push(uint _number) public returns (bool) {
        bytes32 currentId = head;
        uint currentNumber = items[currentId].number;

        if (_number < currentNumber) {
            if (numInList < LIST_SIZE) {
                // Insert at head
                SenderWithNumber memory item = SenderWithNumber(head, _number, msg.sender);
                head = createId(msg.sender, _number);
                items[head] = item;
                return true;
            } else {
                return false;
            }
        }

        // Traverse list and insert when appropriate
        bytes32 nextId = items[currentId].next;
        while (nextId != 0x0) {
            uint nextNumber = items[nextId].number;

            if (nextNumber >= _number) {
                // Insert middle
                insertBetween(msg.sender, _number, currentId, nextId);

                return true;
            }

            currentId = nextId;
            nextId = items[nextId].next;
        }

        // Insert at end
        insertBetween(msg.sender, _number, currentId, 0x0);
        return true;

    }

    function insertBetween(address sender, uint number, bytes32 prevId, bytes32 nextId) private {
        bytes32 id = createId(sender, number);
        SenderWithNumber memory item = SenderWithNumber(nextId, number, sender);
        items[id] = item;

        // Set previous pointer to current
        items[prevId].next = id;


        // Advance head if list is full
        if (numInList == LIST_SIZE)  {
            head = items[head].next;
            // TODO: May be able to get a gas refund for zeroing the previous head out
        } else { // Otherwise just increment
            numInList++;
        }
    }

    function createId(address sender, uint value) public view returns (bytes32) {
        return keccak256(abi.encodePacked(sender, value, block.timestamp));
    }

    function getSortedList() public view returns (uint[] memory) {
        uint[] memory list = new uint[](numInList);
        uint index = 0;
        SenderWithNumber memory item = items[head];
        while (item.next != 0x0 && index < numInList) {
            list[index] = item.number;
            index++;
            item = items[item.next];
        }
        return list;
    }

}