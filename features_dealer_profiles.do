/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/DP_forms.dta
* Purpose: Creates features for bogus firms from DP
		   These are input for the ML tool 
* Output: 
			
* Author: Ashwin MB
* Date: 28/11/2018
* Last modified: 28/11/2018 (Ashwin)
****************************************************/

** Initializing environment

clear all
version 1
set more off
qui cap log c
set mem 100m

*--------------------------------------------------------
** Setting directories and files
*--------------------------------------------------------

*input files*
global input_path1 "H:/Ashwin/dta/original"
global input_path2 "H:/Ashwin/dta/intermediate"
global input_path3 "H:/Ashwin/dta/intermediate2"
global temp_path1 "H:/Ashwin/dta/temp"
global old_path "D:/data"

*output files*
global features_path "H:/Ashwin/dta/BogusDealers"
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"
global sample_path "H:/Ashwin/dta/sample"

*--------------------------------------------------------
** Cleaning variables
*--------------------------------------------------------

use "${output_path}/dp_form.dta", clear

// First we import the date from the registration date
//gen RegistrationYear=dofc(RegistrationDate)
//format %td RegistrationYear //change it into date format
//Import just the year inf
gen RegistrationYear = RegistrationDate
gen StartYear=yofd(RegistrationYear)
gen StartMonth=mofd(RegistrationYear)
//Changing the format to appropriate year form

format %tm StartMonth
format %ty StartYear 

gen DummyRetailer = 0
gen DummyManufacturer = 0
gen DummyWholeSaler = 0 
gen DummyInterStateSeller = 0 
gen DummyInterStatePurchaser = 0
gen DummyWorkContractor = 0
gen DummyImporter = 0
gen DummyExporter = 0 
gen DummyOther = 0
gen DummyHotel=0
gen DummyECommerce=0


replace DummyManufacturer = 1 if(regexm(Nature, "Manufacturer"))
replace DummyManufacturer = 1 if(regexm(Nature, "Manufecturer"))
replace DummyManufacturer = 1 if(regexm(Nature, "Manufacturing"))
replace DummyManufacturer = 1 if(regexm(Nature, "MANUFACTURER"))



replace DummyRetailer = 1 if(regexm(Nature, "Retail Trader"))
replace DummyRetailer = 1 if(regexm(Nature, "Retailer"))
replace DummyRetailer = 1 if(regexm(Nature, "RETAILER"))
replace DummyRetailer = 1 if(regexm(Nature, "RETAIL SALE"))
replace DummyRetailer = 1 if(regexm(Nature, "RETAIL TRADER"))


replace DummyWholeSaler = 1 if(regexm(Nature, "Wholesale Trader"))
replace DummyWholeSaler = 1 if(regexm(Nature, "Wholesaler"))
replace DummyWholeSaler = 1 if(regexm(Nature, "WHOLESALER"))
replace DummyWholeSaler = 1 if(regexm(Nature, "WHOLESALE DEALER"))
replace DummyWholeSaler = 1 if(regexm(Nature, "WHOLESELLER"))
replace DummyWholeSaler = 1 if(regexm(Nature, "wholeseller"))
replace DummyWholeSaler = 1 if(regexm(Nature, "wholesaler"))

replace DummyInterStateSeller = 1 if(regexm(Nature, "Interstate Seller"))
replace DummyInterStateSeller = 1 if(regexm(Nature, "INTERSTATE PURCHASER AND SELLER"))
replace DummyInterStateSeller = 1 if(regexm(Nature, "INTERSTATE SALE/PURCHASE"))
replace DummyInterStateSeller = 1 if(regexm(Nature, "INTERSTATE SELLER AND PURCHASER"))
replace DummyInterStateSeller = 1 if(regexm(Nature, "INTERSTATE SELLER"))
replace DummyInterStateSeller = 1 if(regexm(Nature, "Inter State Seller"))

replace DummyInterStatePurchaser = 1 if(regexm(Nature, "Interstate Purchaser"))
replace DummyInterStatePurchaser = 1 if(regexm(Nature, "INTERSTATE SALE/PURCHASE"))
replace DummyInterStatePurchaser = 1 if(regexm(Nature, "INTERSTATE SELLER AND PURCHASER"))
replace DummyInterStatePurchaser = 1 if(regexm(Nature, "INTERSTATE PURCHASER"))
replace DummyInterStatePurchaser = 1 if(regexm(Nature, "INTERSTATE PURCHASER AND SELLER"))
replace DummyInterStatePurchaser = 1 if(regexm(Nature, "Inter State Purchaser"))



replace DummyWorkContractor = 1 if(regexm(Nature, "Work Contractor"))
replace DummyWorkContractor = 1 if(regexm(Nature, "WORK CONTRACTOR"))
replace DummyWorkContractor = 1 if(regexm(Nature, "WORKCONTRACT"))
replace DummyWorkContractor = 1 if(regexm(Nature, "WORK CONTRACT"))
replace DummyWorkContractor = 1 if(regexm(Nature, "CONTRACTOR"))
replace DummyWorkContractor = 1 if(regexm(Nature, "Contractor"))

replace DummyOther = 1 if(regexm(Nature, "Other"))
replace DummyOther = 1 if(regexm(Nature, "OTHER"))

replace DummyImporter = 1 if(regexm(Nature, "Importer"))
replace DummyImporter = 1 if(regexm(Nature, "IMPORTER/EXPORTER"))
replace DummyImporter = 1 if(regexm(Nature, "IMPORTER"))

replace DummyExporter = 1 if(regexm(Nature, "Exporter"))
replace DummyExporter = 1 if(regexm(Nature, "EXPORTER"))

replace DummyHotel = 1 if(regexm(Nature, "Restaurent"))
replace DummyHotel = 1 if(regexm(Nature, "RESTURANT"))
replace DummyHotel = 1 if(regexm(Nature, "HOTEL"))
replace DummyHotel = 1 if(regexm(Nature, "RESTAURENT"))
replace DummyHotel = 1 if(regexm(Nature, "RESTAURANT"))
replace DummyHotel = 1 if(regexm(Nature, "RESTURENT"))
replace DummyHotel = 1 if(regexm(Nature, "CATERING"))
replace DummyHotel = 1 if(regexm(Nature, "Restaurant"))
replace DummyHotel = 1 if(regexm(Nature, "HOTELS"))
replace DummyHotel = 1 if(regexm(Nature, "CANTEENS"))
replace DummyHotel = 1 if(regexm(Nature, "Banquet"))
replace DummyHotel = 1 if(regexm(Nature, "Catering"))
replace DummyHotel = 1 if(regexm(Nature, "BANQUET"))
replace DummyHotel = 1 if(regexm(Nature, "Banquet"))
replace DummyHotel = 1 if(regexm(Nature, "RESTURAENT"))
replace DummyHotel = 1 if(regexm(Nature, "COFFEE SHOP"))
replace DummyHotel = 1 if(regexm(Nature, "RESTURAENT"))
replace DummyHotel = 1 if(regexm(Nature, "hotel industry"))
replace DummyHotel = 1 if(regexm(Nature, "CATERERS"))

replace DummyECommerce = 1 if(regexm(Nature, "E COMMERCE"))
replace DummyECommerce = 1 if(regexm(Nature, "Online Seller"))
replace DummyECommerce = 1 if(regexm(Nature, "Online Trading"))
replace DummyECommerce = 1 if(regexm(Nature, "ONLINE TRADING"))
replace DummyECommerce = 1 if(regexm(Nature, "E Commerce"))
replace DummyECommerce = 1 if(regexm(Nature, "Ecommerce"))
replace DummyECommerce = 1 if(regexm(Nature, "Website Retailing"))
replace DummyECommerce = 1 if(regexm(Nature, "E Commerece"))
replace DummyECommerce = 1 if(regexm(Nature, "ECOMMERCE"))
replace DummyECommerce = 1 if(regexm(Nature, "ONLINE SHOPPING"))


gen DummyTelecom=0
replace DummyTelecom=1 if (regexm(Nature, "Telecom"))
replace DummyTelecom=1 if (regexm(Nature, "TELECOM"))
replace DummyTelecom=1 if (regexm(Nature, "DTH SERVICE"))
replace DummyTelecom=1 if (regexm(Nature, "Internet Service Provider"))

//drop ExpectedTurnover TurnoverPreviousYear OwnCapital BankLoan PlantAndMachinery LandAndBuilding OtherAssets Boolean201011 Boolean201112 Boolean201213 BooleanCounsel BooleanThirdPartyStorage GTONil201213

replace DummyRetailer=-1 if Nature==""
replace DummyManufacturer=-1 if Nature==""
replace DummyWholeSaler=-1 if Nature==""
replace DummyInterStateSeller=-1 if Nature==""
replace DummyInterStatePurchaser=-1 if Nature==""
replace DummyWorkContractor=-1 if Nature==""
replace DummyImporter=-1 if Nature==""
replace DummyExporter=-1 if Nature==""
replace DummyOther=-1 if Nature==""
replace DummyHotel=-1 if Nature==""
replace DummyECommerce=-1 if Nature==""
replace DummyTelecom=-1 if Nature==""

replace Constitution="MISSING INFORMATION" if Constitution==""

replace Ward="-100" if Ward==""
//replace PhysicalWard="-100" if PhysicalWard==""
replace StartYear=-200 if StartYear==.

*Original code Variables are numbers (Yes =1, No=0) 
*Changing accordingly
replace BooleanRegisteredCE = "1" if BooleanRegisteredCE == "Yes"
replace BooleanRegisteredCE = "0" if BooleanRegisteredCE == "No"
destring BooleanRegisteredCE, replace
replace BooleanRegisteredCE=-200 if BooleanRegisteredCE==.

replace BooleanRegisteredIEC = "1" if BooleanRegisteredIEC == "Yes"
replace BooleanRegisteredIEC = "0" if BooleanRegisteredIEC == "No"
destring BooleanRegisteredIEC, replace
replace BooleanRegisteredIEC=-200 if BooleanRegisteredIEC==.

replace BooleanServiceTax = "1" if BooleanServiceTax == "Yes"
replace BooleanServiceTax = "0" if BooleanServiceTax == "No"
destring BooleanServiceTax, replace
replace BooleanServiceTax=-200 if BooleanServiceTax==.

save "${features_path}\FeatureDealerProfiles.dta", replace

/* Cleaning to retain columns that are found in the old data */
use "${features_path}\FeatureDealerProfiles.dta", clear
drop Zone CommoditiesInterstate SaleWise PurchaseWise TurnoverPreviousYear

save "${features_path}\FeatureDealerProfiles.dta", replace

/* Checking values */

tab DummyRetailer

* High number of missing values found in the new DP data
/*
DummyRetail |
         er |      Freq.     Percent        Cum.
------------+-----------------------------------
         -1 |    421,906       61.45       61.45
          0 |     80,496       11.72       73.18
          1 |    184,163       26.82      100.00
------------+-----------------------------------
      Total |    686,565      100.00

*/



