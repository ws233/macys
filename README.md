macys
=====

task: https://github.com/ws233/macys/blob/master/iOS%20Programming%20Assignment2.docx

Dependencies:
1. 'FMDB', since Core Data is not used in the project at all. Instead there are direct access to sqlite database using SQL requests.
2. 'Base64' to convert image data to bas64 strings to store into database. Is used cause the ''base64EncodedDataWithOptions: and base64EncodedStringWithOptions:' standard iOS functions are not available in iOS 6.

There are three tables to store Product, Store, and Color entities. There are also two tables to store the links between those entities: Product -> Stores, Product -> Colors. There is an ability to add only Products and no ability to add Colors and Stores. The laters are being created during first run and never changed from the application. But it's available to add them to the Product entity.

There is only one thread being used in the application, no multithreading yet. That's why an application can freeze for a long time, during first run initialization or saving a huge pictures to database. It’s better to move all the database related code into background thread, showing some loader or progress bar in the UI, while it works. Furthermore, it’s not a good choose to store image right into database. It makes the database slow. Instead, it’s better to save images right into hard drive and save the link to the image file into database.

Also, it’s better to work with database using Core Data, instead of direct access to sqlite. There is no significant advantages of direct access, but opposite a lot, while using CoreData. They are great code simplicity, free memory management for data entities while memory lack (On the iPhone, it does a great job of batching fetches to minimize memory usage), undo/redo for free, easy database migrations.

Also there is only a few error checks in the code, cause I don’t have enough time to make the code full-covered with error checks.

Also the UI is not user friendly due to the lack of time as well ^^.
