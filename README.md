# Cloud Kitchen Challenge

## Notes
- As a rule of gold, I've always created bulkified code, mainly in Salesforce, due to governor limits;
  - In this specific case, the REST endpoint accepts a payload with a JSON containing a single record to be created, but can be easily modified to handle several records at the same time;
- I've always prefered Database Methods as means of DML operations;
  - Not only we can have up to 150 of them per execution, we can also query way more records than with SOQL, as long as we respect the heap size and governor limits;
- I've used a Database.DMLOptions to override the duplicate_record monitoring, since I've built a code workflow in which I avoid duplicating any record;
- Not all test Classes covers 100% of the code. Some are using Dependency Injection to effect the best cover possible;
  - I would have created Helper Classes if more time was given, to hold utility methods like creation of SObject instances and JSON deserialization;
- My key goal here was to ensure data quality and type consistency, owing it to the fact that a data model wasn't provided (sample JSON);
  - For that, I had to build Classes that act as Models, encapsulating data easily - even if it seems more complex. One advantage of that is that we can build JSON configuration files accordingly to OpenAPI specification, allowing remote systems to map their data against our Models in a more streamlined way

## Highlights
Key challenges here were that no formal naming convention, file architecture or data models were provided, other than a brief list of possible properties.
Time constraint was half as challenging as the above-mentioned issues. Hardly possible to change the design pattern midway through construction - doable but still risky.
