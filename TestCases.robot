*** Settings ***
Documentation   Auto1/QA Task
Library         SeleniumLibrary
Library         String
Library         helpers.py
Library         Collections
Suite Setup     Open URL Locally
Suite Teardown  Close Browser


*** Test Cases ***
TC1 - Check Filters on Advanced Searh Page
    Given Open URL AutoHero
    And User is on Advanced Search Page
    When User Select Filter for First registration
    And User Select Filter for Price Decsending
    Then Verify all cars are filtered by First Registration
    And Verify all Cars are Filtered By Price Descending


*** Keywords ***
Open Tests in Souce Labs
    ${desired_capabilities}=    Create Dictionary
    Set to Dictionary    ${desired_capabilities}    build    test_run
    Set to Dictionary    ${desired_capabilities}    platformName    Windows 10
    Set to Dictionary    ${desired_capabilities}    name    Auto1
    Set to Dictionary    ${desired_capabilities}    browserName    chrome

    ${executor}=    Evaluate          str('http://milan.novovic:0f772a45-b623-4d44-a01f-9a1db40f0d5d@ondemand.saucelabs.com:80/wd/hub')
    Create Webdriver    Remote      desired_capabilities=${desired_capabilities}    command_executor=${executor}


Open URL Locally
    #Open Webdriver hosted on Azure Devops
    Create Webdriver    Chrome    executable_path=D:/a/1/s/node_modules/chromedriver/lib/chromedriver/chromedriver.exe
    Maximize Browser Window

Open URL AutoHero
    Go To    https://www.autohero.com

User is on Advanced Search Page
    Sleep   2s
    Click Element                       //button[contains(text(),'Alles akzeptieren')]
    Sleep   1s
    Click Element                       //a[contains(text(),'Finde dein Auto')]
    Wait Until Element Is Visible       //span[contains(text(),'Erstzulassung')]

User Select Filter for First registration
    Click Element                        //span[contains(text(),'Erstzulassung')]
    Wait Until Element Is Visible        //select[@id='rangeStart']/*[text()='2014']
    Click Element                        //select[@id='rangeStart']/*[text()='2014']
    #Click Element                        //a[contains(text(),'Ergebnisse')]

Verify all cars are filtered by first registration

#This Keyword  will take all elements with registration,
#pass it to python method which will return if there are registration before 2014

    Sleep   1s

    @{locators}    Get Webelements      //*[contains(@class,'specItem___')][1]
    @{result}=       Create List

    FOR   ${locator}   IN    @{locators}
               ${name}=    Get Text    ${locator}
               ${matches}=		Get Regexp Matches      ${name}  	\\d{4}
               Append To List   ${result}    ${matches}
         ${flat}    Evaluate    [item for sublist in ${result} for item in (sublist if isinstance(sublist, list) else [sublist])]

    ${numbs}=    Convert To Integer   2014
    END

    FOR   ${locator}   IN    @{flat}
       Log   ${locator}
       Run Keyword Unless  ${locator} >= ${numbs}      Pass
    END

User Select Filter for Price Decsending
    Wait Until Element Is Visible    //*[@id="app"]/div/main/div/div[3]/div/div[1]/button[8]
    Click Element                    //*[@id="app"]/div/main/div/div[3]/div/div[1]/button[8]
    Sleep   3s
    Click Element    //select[@id="sortBy"]
    Select From List by Value    //select[@id="sortBy"]    4

Verify all Cars are Filtered By Price Descending

#Take all prices, create a list, and return as float so to check if list is sorted

    Sleep   2s
    @{locators}    Get Webelements      //*[contains(@class,'totalPrice')][1]
    ${priceAll}=       Create List
    ${sortedList}=       Create List
    FOR   ${locator}   IN    @{locators}
               ${name}=    Get Text    ${locator}
               ${matches}=		Get Regexp Matches      ${name}  	\^.....
               Append To List  ${priceAll}  ${matches}
        ${flat}    Evaluate    [item for sublist in ${priceAll} for item in (sublist if isinstance(sublist, list) else [sublist])]
    END

    ${sortPrices}=    Sort List     ${flat}

    Should Be Equal as Strings     ${sortPrices}   True

    Log  ${sortPrices}
    Log  ${flat}