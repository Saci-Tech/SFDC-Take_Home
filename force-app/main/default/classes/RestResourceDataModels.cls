public class RestResourceDataModels {
    public class SiteContactData {
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
        
        public SiteContactData() {}

        public SiteContactData(String firstName, String lastName, String email, String phone) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.email = email;
            this.phone = phone;
        }
    }
    public class SiteProductData {
        public String name { get; set; }
        public String uuid { 
            get {
                return this.name;
            }
            set { 
                // helps to ensure that the UUID is really unique per product
                this.uuid = value.toLowerCase(); 
            }
        }
        
        public SiteProductData() {}

        public SiteProductData(String name, String uuid) {
            this.name = name;
            this.uuid = uuid;
        }
    }
    public class SiteAddressData {
        public String street { get; set; }
        public String city { get; set; }
        public String state { get; set; }
        public String postalCode { get; set; }
        public String country { get; set; }

        public SiteAddressData() {}

        public SiteAddressData(String street, String city, String state, String postalCode, String country) {
            this.street = street;
            this.city = city;
            this.state = state;
            this.postalCode = postalCode;
            this.country = country;
        }
    }
    public class SiteIncomingData {
        public String companyName { get; set; }
        public SiteContactData contact { get; set; }
        public List<SiteProductData> products { get; set; }
        public SiteAddressData address { get; set; }

        public SiteIncomingData() {}

        public SiteIncomingData(SiteContactData contact, String companyName, List<SiteProductData> products, SiteAddressData address) {
            this.companyName = companyName;
            this.products = products != null ? products : new List<SiteProductData>();
            this.address = address != null ? address : new SiteAddressData();
            this.contact = contact != null ? contact : new SiteContactData();

        }
    }

    public class ResponseDataModel {
        public Integer status { get; set; }
        public String message { get; set; }

        public ResponseDataModel() {}
        public ResponseDataModel(Integer status, String message) {
            this.status = status;
            this.message = message
        }
    }
}