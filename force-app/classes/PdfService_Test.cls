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

        Test.startTest();
        PdfService.PdfFileRequest emptyRequest = new PdfService.PdfFileRequest();
        PdfService.execute(new List<PdfService.PdfFileRequest>{
            new PdfService.PdfFileRequest(c.Id, PdfService.TEST_PDF_CONTENT)
        });
        Test.stopTest();

        ContentVersion cv = [SELECT VersionData FROM ContentVersion LIMIT 1];
        Assert.areEqual(Blob.valueOf(PdfService.TEST_PDF_CONTENT).toString(), cv.VersionData.toString(), 'File not created properly by PdfService.PdfFileRequest method!');
    }
}
