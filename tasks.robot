*** Settings ***
Documentation       Orders robot with robocorp certification

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Excel.Files
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Dialogs
Library             RPA.Robocloud.Secrets


*** Tasks ***
Orders robot with robocorp certification
    Open browser
    ${get_data_order}=    Download excel file
    FOR    ${row}    IN    @{get_data_order}
        Close the popUp
        Log    ${row}
        Fill the form    ${row}
        Preview the robot
        Wait Submit
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to next order robot
    END
    Create a ZIP file of the receipts
    [Teardown]    Log out and close the browser


*** Keywords ***
Open browser
    ${link}=    Get Secret    credentials
    #Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Open Available Browser    ${link}[url]

Download excel file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${order_data}=    Read table from CSV    orders.csv    dialect=excel
    Log    Found columns: ${order_data.columns}
    RETURN    ${order_data}

Close the popUp
    Click Button    OK

Fill the form
    [Arguments]    ${row}
    ${legs}=    Convert To Integer    ${row}[Legs]
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${legs}
    Input Text    address    ${row}[Address]

Wait Submit
    Wait Until Keyword Succeeds    30 sec    1 sec    Submit the order and wait success messagge

Submit the order and wait success messagge
    Click button    Order
    #Click Element    order
    Element Should Be Visible    xpath://div[@id="receipt"]/p[1]
    Element Should Be Visible    id:order-completion

Preview the robot
    Click Element    id:preview
    Wait Until Element Is Visible    id:robot-preview

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    id:order-completion
    ${order_number}=    Get Text    xpath://div[@id="receipt"]/p[1]
    #Log    ${order_number}
    ${receipt_html}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${receipt_html}    ${CURDIR}${/}output${/}receipts${/}${order_number}.pdf
    RETURN    ${CURDIR}${/}output${/}receipts${/}${order_number}.pdf

Take a screenshot of the robot
    [Arguments]    ${order_number}
    Screenshot    id:robot-preview    ${CURDIR}${/}output${/}${order_number}.png
    RETURN    ${CURDIR}${/}output${/}${order_number}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Log    ${pdf}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}
    #Close Pdf    ${pdf}
    Close Pdf

Go to next order robot
    Click Button    order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${CURDIR}${/}output${/}receipts    ${CURDIR}${/}output${/}receipt.zip

Log out and close the browser
    Close Browser
