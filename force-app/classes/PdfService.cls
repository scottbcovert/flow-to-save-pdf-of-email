public with sharing class PdfService {

    public static final Integer CACHE_MAX_KEY_LENGTH = 50;
    public static final String CACHE_PARTITION = 'local.PdfService';
    private static final Integer CACHE_TTL = 300; // Default TTL for each cache entry to 5 minutes
    @TestVisible
    private static final String TEST_PDF_CONTENT = 'TEST CONTENT';

    private static String createCacheKey(String uuid) {
        String encodedUuid = EncodingUtil.convertToHex(Blob.valueOf(uuid));
        String cacheKey = CACHE_PARTITION + '.' + encodedUuid;
        cacheKey = cacheKey.length() <= CACHE_MAX_KEY_LENGTH ? cacheKey : cacheKey.substring(0, CACHE_MAX_KEY_LENGTH);
        return cacheKey;
    }

    private static void clearPdfCacheEntry(String uuid) {
        Cache.Org.remove(createCacheKey(uuid));
    }

    private static void createPdfCacheEntry(String pdfContent, String uuid) {
        Cache.Org.put(createCacheKey(uuid), pdfContent, CACHE_TTL);
    }

    private static void createPdfFile(Id recordId, String uuid) {
        PageReference pdfPage = Page.PdfContainer;
        pdfPage.getParameters().put('key',createCacheKey(uuid));
        String fileName = uuid;
        ContentVersion cv = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName + '.pdf',
            VersionData = Test.isRunningTest() ? Blob.valueOf(TEST_PDF_CONTENT) : pdfPage.getContentAsPDF()
        );
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        clearPdfCacheEntry(uuid);
    }

    @InvocableMethod(label='Create PDF File' description='Creates a PDF file containing given rich text on a given record id' category='PDF')
    public static void execute(List<PdfFileRequest> requests) {
        for (PdfFileRequest r : requests) {
            String uuid = String.valueOf(UUID.randomUUID());
            createPdfCacheEntry(r.pdfContent, uuid);
            System.enqueueJob(new PdfService.PdfQueueable(r.recordId, uuid));
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

    public class PdfQueueable implements Queueable, Database.AllowsCallouts {

        private Id recordId;
        private String uuid;

        public PdfQueueable(Id recordId, String uuid) {
            this.recordId = recordId;
            this.uuid = uuid;
        }

        public void execute(QueueableContext QueueableContext) {
            createPdfFile(recordId, uuid);
        }
    }
}
