
Here are some imaginary install instructions.

1. Install the trucker gem and add to your gem config block.

2. Generate the basic trucker files

    script/generate truck

    - Add legacy adapter to database.yml
    - Add legacy base class
    - (Optionally) Add legacy sub classes for all existing models
    - Add app/models/legacy to load path in Rails Initializer config block
    - Generate sample migration task (using pluralized model names)
  
3. Update database.yml with legacy database info

4. Run rake db:create:all to create the legacy database

5. Import your legacy database.
   (Make sure the legacy adapter is using the correct name.)

6. Update legacy model table names as needed

7. Update legacy model field mappings as needed

8. Start migrating!
   rake db:migrate:models

 