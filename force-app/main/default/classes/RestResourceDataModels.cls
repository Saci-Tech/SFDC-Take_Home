public class RestResourceDataModels {
    public class SiteContactData {
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
        
        public SiteContactData() {}
        public SiteContactData(String firstName, String lastName, String email, String phone) {}
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
        public List<SiteProductData> products { get; set; }
        public SiteAddressData address { get; set; }

        public SiteIncomingData() {}

        public SiteIncomingData(String firstName, String lastName, String companyName, String email, String phone, List<SiteProductData> products, SiteAddressData address) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.companyName = companyName;
            this.email = email;
            this.phone = phone;
            this.products = products != null ? products : new List<SiteProductData>();
            this.address = address != null ? address : new SiteAddressData();
        }
    }
}