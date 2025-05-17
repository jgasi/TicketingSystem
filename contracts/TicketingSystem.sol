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
        uint256 resalePrice;
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

    // Dohvat informacija o događaju
    function getEventDetails(uint256 _eventId) public view returns (
        string memory,
        string memory,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) {
        Event storage eventInstance = events[_eventId];
        return (
            eventInstance.eventName,
            eventInstance.eventLocation,
            eventInstance.eventDate,
            eventInstance.maxTickets,
            eventInstance.ticketPrice,
            eventInstance.eventOwner,
            eventInstance.ticketsSold
        );
    }

    // Kupnja ulaznice za odredjeni event
    function buyTicket(uint256 _eventId) public payable {
        Event storage eventInstance = events[_eventId];
        
        require(eventInstance.eventOwner != address(0), "Event ne postoji.");
        require(eventInstance.ticketsSold < eventInstance.maxTickets, "Nema dostupnih ulaznica.");
        require(msg.value == eventInstance.ticketPrice, "Pogresna cijena ulaznice.");

        tickets[nextTicketId] = Ticket({
            ticketId: nextTicketId,
            owner: msg.sender,
            isForSale: false,
            resalePrice: 0
        });

        ownerTickets[msg.sender].push(nextTicketId);

        eventInstance.ticketsSold++;
        nextTicketId++;
    }

    // Dohvat svih ulaznica od vlasnika
    function getOwnerTickets(address _owner) public view returns (uint256[] memory) {
        return ownerTickets[_owner];
    }

    // Pokretanje zahtjeva za preprodaju
    function requestResellTicket(uint256 _ticketId, uint256 _resellPrice) public {
        Ticket storage ticketInstance = tickets[_ticketId];

        require(ticketInstance.owner == msg.sender, "Niste vlasnik ove ulaznice.");
        require(!ticketInstance.isForSale, "Ulaznica je vec na prodaji.");
        
        ticketInstance.isForSale = false;
        ticketInstance.resalePrice = _resellPrice;
    }

    // Odobravanje preprodaje
    function approveResell(uint256 _ticketId, bool _status) public {
        Ticket storage ticketInstance = tickets[_ticketId];
        require(ticketInstance.owner == msg.sender, "Niste vlasnik ove ulaznice.");
        ticketInstance.isForSale = _status;
    }

    // Kupnja ulaznice iz preprodaje
    function buyResoldTicket(uint256 _ticketId) public payable {
        Ticket storage ticketInstance = tickets[_ticketId];

        require(ticketInstance.isForSale, "Ulaznica nije na prodaji.");
        require(msg.value == ticketInstance.resalePrice, "Pogresna cijena ulaznice.");
        
        address previousOwner = ticketInstance.owner;

        // Prenosimo vlasništvo
        ticketInstance.owner = msg.sender;
        ticketInstance.isForSale = false;
        ticketInstance.resalePrice = 0;

        // Prebacivanje novca vlasniku
        payable(previousOwner).transfer(msg.value);
    }

    // Provjera autentičnosti ulaznice
    function verifyTicket(uint256 _ticketId, address _owner) public view returns (bool) {
        Ticket storage ticketInstance = tickets[_ticketId];
        return ticketInstance.owner == _owner;
    }

    // Otkazivanje događaja
    function cancelEvent(uint256 _eventId) public {
        Event storage eventInstance = events[_eventId];

        require(eventInstance.eventOwner == msg.sender, "Niste vlasnik ovog dogadaja.");
        require(eventInstance.ticketsSold == 0, "Ne mozete otkazati dogadaj s prodanim ulaznicama.");

        delete events[_eventId];
    }

    // Promjena cijene ulaznica
    function changeTicketPrice(uint256 _eventId, uint256 _newPrice) public {
        Event storage eventInstance = events[_eventId];

        require(eventInstance.eventOwner == msg.sender, "Niste vlasnik ovog dogadaja.");
        require(_newPrice > 0, "Cijena mora biti veca od 0.");
        require(eventInstance.ticketsSold == 0, "Ne mozete mijenjati cijenu nakon prodaje ulaznica.");

        eventInstance.ticketPrice = _newPrice;
    }

    // Administracija i informacije
    function getEventCount() public view returns (uint256) {
        return nextEventId - 1;
    }

    function getTicketCount() public view returns (uint256) {
        return nextTicketId - 1;
    }
}