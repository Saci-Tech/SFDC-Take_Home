@isTest
public class RestResourceDataModelsTest {

    @isTest
    static void testSiteContactDataInitialization() {
        RestResourceDataModels.SiteContactData contactData = new RestResourceDataModels.SiteContactData('John', 'Doe', 'john@example.com', '1234567890');

        System.assertEquals('John', contactData.firstName);
        System.assertEquals('Doe', contactData.lastName);
        System.assertEquals('john@example.com', contactData.email);
        System.assertEquals('1234567890', contactData.phone);
    }

    @isTest
    static void testSiteProductDataInitialization() {
        RestResourceDataModels.SiteProductData productData = new RestResourceDataModels.SiteProductData('abc123', 5);

        System.assertEquals(5, productData.quantity);
        System.assertEquals('abc123', productData.uuid);
    }

    @isTest
    static void testSiteAddressDataInitialization() {
        RestResourceDataModels.SiteAddressData addressData = new RestResourceDataModels.SiteAddressData('123 Main St', 'Cityville', 'CA', '90210', 'USA');

        System.assertEquals('123 Main St', addressData.street);
        System.assertEquals('Cityville', addressData.city);
        System.assertEquals('CA', addressData.state);
        System.assertEquals('90210', addressData.postalCode);
        System.assertEquals('USA', addressData.country);
    }

    @isTest
    static void testSiteIncomingDataInitialization() {
        RestResourceDataModels.SiteContactData contactData = new RestResourceDataModels.SiteContactData('John', 'Doe', 'john@example.com', '1234567890');
        RestResourceDataModels.SiteProductData productData = new RestResourceDataModels.SiteProductData('abc123', 5);
        RestResourceDataModels.SiteAddressData addressData = new RestResourceDataModels.SiteAddressData('123 Main St', 'Cityville', 'CA', '90210', 'USA');

        RestResourceDataModels.SiteIncomingData incomingData = new RestResourceDataModels.SiteIncomingData('Test Company', new List<RestResourceDataModels.SiteProductData>{productData}, contactData, addressData);

        System.assertEquals('Test Company', incomingData.companyName);
        System.assertEquals(contactData, incomingData.contact);
        System.assertEquals(addressData, incomingData.address);
        System.assertEquals(1, incomingData.products.size());
        System.assertEquals(productData, incomingData.products[0]);
    }

    @isTest
    static void testResponseDataModelInitialization() {
        RestResourceDataModels.ResponseDataModel responseData = new RestResourceDataModels.ResponseDataModel(200, 'Success');

        System.assertEquals(200, responseData.status);
        System.assertEquals('Success', responseData.message);

        RestResourceDataModels.SiteAddressData address = new RestResourceDataModels.SiteAddressData();
        System.assert(address != null);

        RestResourceDataModels.SiteProductData product = new RestResourceDataModels.SiteProductData();
        System.assert(product != null);

        RestResourceDataModels.SiteContactData contact = new RestResourceDataModels.SiteContactData();
        System.assert(contact != null);

        RestResourceDataModels.SiteIncomingData data = new RestResourceDataModels.SiteIncomingData();
        System.assert(data != null);

        RestResourceDataModels.ResponseDataModel response = new RestResourceDataModels.ResponseDataModel();
        System.assert(response != null);
    }
}
