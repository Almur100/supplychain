// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint);
    function approve(address spender, uint256 amount) external returns (bool);
     function allowance(address owner, address spender) external view returns (uint256); 

}

contract supplychain{

    struct Manufacturer{
        address manufactureraddress;
        uint price;
        bytes location;
        bytes contactdetails;
        bytes productdetails;
        bytes quantitydetails;
    }
    struct Wholeseller{
        address wholeselleraddress;
        bytes location;
        bytes contactdetails;
        uint price;
        bytes quantitydetails;
        bytes productdetails;

    }
    struct Retailer{
        address retaileraddress;
        bytes location;
        bytes contactdetails;
        uint  price;
        bytes quantitydetails;
        bytes productdetails;

    }

    mapping(address => Manufacturer) manufacturerdetails;
    mapping(address => Wholeseller) wholesellerdetails;
    mapping(address => Retailer) retailerdetails;
    mapping(address => bool) private exist;
    uint private id;
    enum orderstatus{noorder,wholesellerorder,wholesellerbought,retailerorder,retailerbought,consumerorder,consumerbought}
    mapping(uint=> orderstatus) productstatus;
    IERC20 public immutable token;
    //mapping(address => uint[]) productid;
    mapping(address=>mapping(address=> uint)) ordersetup;
    mapping(address=>mapping(address=>uint)) public MW;
    mapping(address=>mapping(address=>uint)) public WR;


    constructor(address _token) {
        token = IERC20(_token);
    }
   // uint constant defaultprice = 0;
    //bytes32 constant defaultval = "0x0000000000000000000000000000000000000000000000000000000000000000"

    function addmanufacturer(uint _price,bytes memory _productdetails,bytes memory _contactdetails,bytes memory _quantity,bytes memory _location) public{
        require(!exist[msg.sender],"addr already exist");
        Manufacturer memory newmanufacture = Manufacturer(msg.sender,_price,_location,_contactdetails,_productdetails,_quantity);
        manufacturerdetails[msg.sender] = newmanufacture;
        //id++;
       // productid[msg.sender].push(id);
        exist[msg.sender] = true;
    }

    function addwholeseller(address manf,bytes memory _contactdetails,bytes memory _location) public{
        require(!exist[msg.sender],"addr already exist");
        Wholeseller memory newwholeseller;
        newwholeseller.wholeselleraddress = msg.sender;
        newwholeseller.location = _location;
        newwholeseller.contactdetails = _contactdetails;
        wholesellerdetails[msg.sender] = newwholeseller;
        MW[manf][msg.sender] = 0;
       
        exist[msg.sender] = true;
    }

    function addretailer(address whols,bytes memory _contactdetails,bytes memory _location) public{
        require(!exist[msg.sender],"addr already exist");
        Retailer memory newretailer;
        newretailer.retaileraddress = msg.sender;
        newretailer.location = _location;
        newretailer.contactdetails = _contactdetails;
        retailerdetails[msg.sender] = newretailer;
        WR[whols][msg.sender] = 0;
       
        exist[msg.sender] = true;
    }

    function wholesellerorder(address _manufacturer ) public{
         require(exist[msg.sender]== true,"addr already exist");
         id++;
        //  productstatus[id] = orderstatus.noorder;
        //  require(productstatus[id] == orderstatus.noorder,"id already ordered");
         productstatus[id] = orderstatus.wholesellerorder;
         ordersetup[msg.sender][_manufacturer] = id;
         

        
    }

    function wholesellerbuy(address _manufacturer,uint _id) public{
        require( MW[_manufacturer][msg.sender] == 0,"you can't proceed");
        require(productstatus[_id] == orderstatus.wholesellerorder,"you can't buy");
        require(ordersetup[msg.sender][_manufacturer] == _id,"you can't buy");
        productstatus[_id] = orderstatus.wholesellerbought;
        Manufacturer memory newmanufacture; 
        uint cost = newmanufacture.price;
        token.transferFrom(msg.sender,_manufacturer,cost);
        MW[_manufacturer][msg.sender] = _id; 
 
    }


    function setwholesellerproduct(address _manufacturer,uint _price,bytes memory _quantity,bytes memory _productdetails,uint _id) public{
        require(exist[msg.sender]== true,"addr not exist");
        require( MW[_manufacturer][msg.sender] == _id,"you can't proceed");
        require(ordersetup[msg.sender][_manufacturer] == _id,"you can't buy");
        require(productstatus[_id] == orderstatus.wholesellerbought,"you can't buyy");  
        
        
        Wholeseller memory newwholeseller;
        newwholeseller.price = _price;
        newwholeseller.quantitydetails = _quantity;
        newwholeseller.productdetails = _productdetails;
        wholesellerdetails[msg.sender] = newwholeseller; 
         



    }


    function retailerrorder(address _manufacturer,address _whloeseller,uint _Wid ) public{
         require(exist[msg.sender],"addr already exist");
         require(MW[_manufacturer][_whloeseller] == _Wid,"you can't order");
         id++;
         //productstatus[id] = orderstatus;
        //  require(productstatus[id] == orderstatus.noorder,"id already ordered");
         productstatus[id] = orderstatus.retailerorder;
         ordersetup[msg.sender][_whloeseller] = id;
         

    }
    function retailerbuy(address _whloeseller,uint _id) public{
        require( WR[_whloeseller][msg.sender] == 0,"you can't proceed");
        require(productstatus[_id] == orderstatus.retailerorder,"you can't buy");
        require(ordersetup[msg.sender][_whloeseller] == _id,"you can't buy");
        productstatus[_id] = orderstatus.retailerbought;
        Wholeseller memory newwholeseller; 
        uint cost = newwholeseller.price;
        token.transferFrom(msg.sender,_whloeseller,cost);
        WR[_whloeseller][msg.sender] = _id; 
 
    }
     function setretailerproduct(address _whloeseller,uint _price,bytes memory _quantity,bytes memory _productdetails,uint _id) public{
        require(exist[msg.sender]== true,"addr not exist");
        require( WR[_whloeseller][msg.sender] == _id,"you can't proceed");
        require(ordersetup[msg.sender][_whloeseller] == _id,"you can't buy");
        require(productstatus[_id] == orderstatus.retailerbought,"you can't buyy");  
        
        
        Retailer memory newretailer;
        newretailer.price = _price;
        newretailer.quantitydetails = _quantity;
        newretailer.productdetails = _productdetails;
        retailerdetails[msg.sender] = newretailer; 
         
         
     }




    

}