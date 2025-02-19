public with sharing class PdfService {

    private static void createPdfAttachment(Id recordId, String pdfContent) {
        PageReference pdfPage = Page.PdfContainer;
        pdfPage.getParameters().put('pdfContent',pdfContent);
        Attachment a = new Attachment(
            Name = String.valueOf(UUID.randomUUID()) + '.pdf',
            Body = Test.isRunningTest() ? Blob.valueOf(pdfContent) : pdfPage.getContentAsPDF(),
            ContentType = 'application/pdf',
            ParentId = recordId
        );
        insert a;
    }

    @InvocableMethod(label='Create PDF Attachment' description='Creates a PDF attachment containing given rich text on a given record id' category='PDF')
    public static void execute(List<PdfAttachmentRequest> requests) {
        for (PdfAttachmentRequest r : requests) {
            createPdfAttachment(r.recordId, r.pdfContent);
        }
    }

    public class PdfAttachmentRequest {

        @InvocableVariable(label='Record Id' description='Id of the record where the PDF attachment should be saved' required=true)
        public Id recordId;

        @InvocableVariable(label='PDF Content' description='Rich text to be used for PDF content' required=true)
        public String pdfContent;

        public PdfAttachmentRequest(Id recordId, String pdfContent) {
            this.recordId = recordId;
            this.pdfContent = pdfContent;
        }

        public PdfAttachmentRequest() {

        }
    }
}
