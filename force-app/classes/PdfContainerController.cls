public with sharing class PdfContainerController {

    public String pdfContent {get; set;}

    public PdfContainerController() {
        String key = ApexPages.currentPage().getParameters().get('key');
        if (key != null) {
            this.pdfContent = Test.isRunningTest() ? key : String.valueOf(Cache.Org.get(key));
        }
    }
}
