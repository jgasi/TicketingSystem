// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketingSystem {

    // Struktura koja predstavlja događaj
    struct Event {
        string eventName;
        string eventLocation;
        uint256 eventDate;
        uint256 maxTickets;
        uint256 ticketPrice;
        address eventOwner;
        uint256 ticketsSold;
    }

    // Struktura koja predstavlja ulaznicu
    struct Ticket {
        uint256 ticketId;
        address owner;
        bool isForSale;
    }

    // Mape događaja i ulaznica
    mapping(uint256 => Event) public events;
    mapping(uint256 => Ticket) public tickets;
    mapping(address => uint256[]) public ownerTickets;

    // Brojači za ID-ove
    uint256 public nextEventId = 1;
    uint256 public nextTicketId = 1;

    // Kreiranje novog događaja
    function createEvent(
        string memory _eventName,
        string memory _eventLocation,
        uint256 _eventDate,
        uint256 _maxTickets,
        uint256 _ticketPrice
    ) public {
        require(_maxTickets > 0, "Broj ulaznica mora biti veci od 0.");
        require(_ticketPrice > 0, "Cijena ulaznice mora biti veca od 0.");
        
        events[nextEventId] = Event({
            eventName: _eventName,
            eventLocation: _eventLocation,
            eventDate: _eventDate,
            maxTickets: _maxTickets,
            ticketPrice: _ticketPrice,
            eventOwner: msg.sender,
            ticketsSold: 0
        });
        
        nextEventId++;
    }

    // Kupnja ulaznice za odredjeni event
    function buyTicket(uint256 _eventId) public payable {
        Event storage eventInstance = events[_eventId];
        
        require(eventInstance.eventOwner != address(0), "Event ne postoji.");
        require(eventInstance.ticketsSold < eventInstance.maxTickets, "Nema dostupnih ulaznica.");
        require(msg.value == eventInstance.ticketPrice, "Pogresna cijena ulaznice.");

        // Kreiranje ulaznice
        tickets[nextTicketId] = Ticket({
            ticketId: nextTicketId,
            owner: msg.sender,
            isForSale: false
        });

        // Dodavanje u mapiranje vlasnika
        ownerTickets[msg.sender].push(nextTicketId);

        // Ažuriranje stanja događaja
        eventInstance.ticketsSold++;
        nextTicketId++;
    }
}