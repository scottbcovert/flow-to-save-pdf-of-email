@IsTest
public with sharing class PdfContainerController_Test {

    private static final String TEST_CONTENT = 'test';

    @IsTest
    static void testConstructor() {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('key',TEST_CONTENT);
        PdfContainerController c = new PdfContainerController();
        Test.stopTest();

        Assert.areEqual(TEST_CONTENT, c.pdfContent, 'File not created properly by PdfService.PdfFileRequest method!');
    }
}
