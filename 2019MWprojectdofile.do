
cd C:\Aggregate_County
//! dir *.csv /a-d /b >C:\filelist.txt
file open myfile using "C:\filelist.txt", read text
file read myfile x
import delimited "`x'"
save  "C:\StataFiles\masterdata.dta", replace
save , replace
clear 

while r(eof)==0 {
import delimited "`x'"
append using  "C:\StataFiles\masterdata.dta"
save  "C:\StataFiles\masterdata.dta", replace  
clear
file read myfile x
}
//Does not work with file read myfile x at the top of while loop because clear clears the local macro x to fix use drop all
use "C:\StataFiles\masterdata.dta"
//keep if industry_code == (10 |7222 |7221 | 722511 |722513)

//keep if own_code == 5



//keep if industry_code == (10 |7222 |7221 | 722511 |722513)

destring industry_code, gen(indcodenum) force
keep if indcodenum == 10 | indcodenum == 7222 | indcodenum == 7221 |indcodenum ==  722511 |indcodenum ==  722513

keep if own_code == 5

//tostring qtr, gen(qtrstring)
//tostring year, gen (yearstring)
//gen yrqtr = yearstring + "q" + qtrstring

gen yq = yq(year, qtr)

//DROP DUPLICATES
sort area_fips yq indcodenum
quietly by area_fips yq indcodenum :  gen dup = cond(_N==1,0,_n)
drop dup

//CREATE TOTAL PRIVATE EMPLOYMENT DATA SET
keep if indcodenum == 10
keep area_fips area_title qtrly_estabs_count month1_emplvl month2_emplvl month3_emplvl total_qtrly_wages yq
save "C:\StataFiles\employment data.dta"
//CREATE  RESTARAUNT DATA
drop if indcodenum == 10
save "C:\StataFiles\nonprivate data.dta"
//CREATE LS RESTARAUNT DATA 
drop if indcodenum == 7221 | indcodenum == 722511
save "C:\StataFiles\limitedserviceemploy.dta"
//CREATE FS RESTARAUNT DATA
keep if indcodenum == 7221 | indcodenum == 722511
save "C:\StataFiles\fullserviceemploy.dta"

//SORT DATA 
use "C:\StataFiles\EmploymentByIndustry\FullServiceEmployment.dta", clear
sort area_fips yq
save "C:\StataFiles\EmploymentByIndustry\FullServiceEmployment.dta", replace
 
use "C:\StataFiles\EmploymentByIndustry\LimitedServiceEmployment.dta"
sort area_fips yq
save "C:\StataFiles\EmploymentByIndustry\LimitedServiceEmployment.dta", replace
 
use "C:\StataFiles\EmploymentByIndustry\TotalPrivateSectorEmployment.dta"
sort area_fips yq
save "C:\StataFiles\EmploymentByIndustry\TotalPrivateSectorEmployment.dta", replace

//Copy and paste to create new data sets
//alternatively use data join command

//RESHAPE POP DATA
import delimited C:\StataFiles\Population\Connecticut.csv, varnames(1) 
reshape long pop, i(ïarea_title) j(year)
save "C:\StataFiles\Population\connecticut.dta"
clear
//Do for each file
//APPENDING GARBAGIO 
use C:\StataFiles\Population\Connecticut.dta
append using C:\StataFiles\Population\STATENAME.dta
//MERGE DATA SETS
use "C:\StataFiles\EmploymentByIndustry\FullServiceEmployment.dta"
merge m:1 area_title year using "C:\StataFiles\Population\masterpopulation.dta"
save "C:\StataFiles\EmploymentByIndustry\FullServiceEmployment.dta", replace
//GEN STATE VAR
gen substate = substr(area_title,-5,5)
merge m:1 substate using "C:\StataFiles\EmploymentByIndustry\StateLevel.dta"
drop substate
drop _merge
save "C:\StataFiles\EmploymentByIndustry\FullServiceEmployment.dta", replace
//ADD STATE MW
merge m:1 state year using "C:\StataFiles\Statemw.dta"
drop _merge
//GEN EMPLOYMENT VARIABLES
drop if pvtemployment ==0
drop if LSemployment ==0
gen pvtemployment = (month1_emplvl_01 + month2_emplvl_01 + month3_emplvl_01)/(3)
gen FSemployment = ( month1_emplvl + month2_emplvl + month3_emplvl) / (3)
sort area_title yq
xtset area_title yq 
//xtreg LSemployment pvtemployment mw pop i.yq, fe
xtreg LSemployment pvtemployment mw pop i.yq, fe
//xtreg lLSemp lpvtemp lmw lpop i.yq, fe


cd C:\StataFiles\StateWide
! dir *.csv /a-d /b >C:\StataFiles\StateWide\filelist.txt
file open myfile using "C:\StataFiles\StateWide\filelist.txt", read text
file read myfile x
import delimited "`x'"
save  "C:\StataFiles\StateWide\masterdata.dta", replace
save , replace
clear


while r(eof)==0 {
import delimited "`x'"
append using  "C:\StataFiles\StateWide\masterdata.dta"
save  "C:\StataFiles\StateWide\masterdata.dta", replace  
clear
file read myfile x
} 
gen yq = yq(year, qtr)
destring industry_code, gen(indcodenum) force
keep if indcodenum == 10 
keep if own_code == 5
drop if dup == 2 
encode area_title, gen(state)
gen totalemp = ( month1_emplvl + month2_emplvl + month3_emplvl) / (3)

gen totalemp1 = totalemp[_n-1]
gen empgrowth = (totalemp - totalemp1)/ totalemp
sysdir set PLUS C:\StataPackages

xtreg lFSemployment lpvtemployment lmw lmwl1 lmwl2 lmwl3 lmwa1 lmwa2 lmwa3 lmwa4 lpop i.yq, fe
//m:1 state year using "C:\StataFiles\laggedmw.dta"
sort state year
quietly by state year :  gen dup = cond(_N==1,0,_n)
//twoway (tsline lsestimates) (tsline fsestimates) (tsline constant, lcolor(black)), ytitle(Lagged Coefficients) ttitle(Year) legend(order(1 "Limited Service" 2 "Full Service"))

esttab, se r2
