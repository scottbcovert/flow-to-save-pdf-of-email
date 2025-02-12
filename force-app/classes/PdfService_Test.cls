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
    static void testCreatePdfAttachment() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        String pdfContent = '<strong>Hello, World!</strong>';

        Test.startTest();
        PdfService.PdfAttachmentRequest emptyRequest = new PdfService.PdfAttachmentRequest();
        PdfService.execute(new List<PdfService.PdfAttachmentRequest>{
            new PdfService.PdfAttachmentRequest(c.Id, pdfContent)
        });
        Test.stopTest();

        Attachment a = [SELECT Body FROM Attachment LIMIT 1];
        Assert.areEqual(Blob.valueOf(pdfContent), a.Body, 'Attachment not created propery by PdfService.PdfAttachmentRequest method!');
    }
}
