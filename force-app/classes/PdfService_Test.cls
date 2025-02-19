@IsTest
public with sharing class PdfService_Test {

    @testSetup
    static void setupTestData() {
        Contact c = new Contact(
            FirstName = 'Johnny',
            LastName = 'Test',
            Email = 'test@test.com'
        );
        insert c;
    }

    @IsTest
    static void testCreatePdfFile() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        String pdfContent = '<strong>Hello, World!</strong>';

        Test.startTest();
        PdfService.PdfFileRequest emptyRequest = new PdfService.PdfFileRequest();
        PdfService.execute(new List<PdfService.PdfFileRequest>{
            new PdfService.PdfFileRequest(c.Id, pdfContent)
        });
        Test.stopTest();

        ContentVersion cv = [SELECT VersionData FROM ContentVersion LIMIT 1];
        Assert.areEqual(Blob.valueOf(pdfContent).toString(), cv.VersionData.toString(), 'File not created properly by PdfService.PdfFileRequest method!');
    }
}
