public with sharing class PdfService {

    private static void createPdfFile(Id recordId, String pdfContent) {
        PageReference pdfPage = Page.PdfContainer;
        pdfPage.getParameters().put('pdfContent',pdfContent);
        String fileName = String.valueOf(UUID.randomUUID());
        ContentVersion cv = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName + '.pdf',
            VersionData = Test.isRunningTest() ? Blob.valueOf(pdfContent) : pdfPage.getContentAsPDF()
        );
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }

    @InvocableMethod(label='Create PDF File' description='Creates a PDF file containing given rich text on a given record id' category='PDF')
    public static void execute(List<PdfFileRequest> requests) {
        for (PdfFileRequest r : requests) {
            createPdfFile(r.recordId, r.pdfContent);
        }
    }

    public class PdfFileRequest {

        @InvocableVariable(label='Record Id' description='Id of the record where the PDF file should be saved' required=true)
        public Id recordId;

        @InvocableVariable(label='PDF Content' description='Rich text to be used for PDF content' required=true)
        public String pdfContent;

        public PdfFileRequest(Id recordId, String pdfContent) {
            this.recordId = recordId;
            this.pdfContent = pdfContent;
        }

        public PdfFileRequest() {

        }
    }
}
