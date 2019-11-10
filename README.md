# WebKitBuilder

This is a script that is currently being developed by me, Yiannis Charalambous. It will help when developing static html/js websites as it will allow code prephab/template support.

This is particularly useful when including common elements in static html websites, such as menu bars in headers, and footers.

How this works:
1. While developing the website, common code will be placed inside ./Imports folder in respective HTML or CSS files (depending on what that code represents).
2. In locations where the common code is to be included, place %(Name of file)% where 'Name of file' is the name of the file inside the ./Imports folder.
3. Before deploying, run the ./build.ps2 script, this will place the 'built' website in, with all the imported code from the imports folder, in the correct location inside the ./Build folder.
4. Deploy the contents of the ./Build folder.
5. Enjoy :)

Some files are excluded from the ./build.ps2 script.

Excluded files:
1. TODO Create exclusion list. You can find it in the script as a global variable currently.

PS: The ./clean.ps2 script deletes the ./Build folder.
