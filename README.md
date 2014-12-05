nonrigidICP
===========

Fork of the Matlab Central package [nonrigidICP by Manu](http://www.mathworks.com/matlabcentral/fileexchange/41396-nonrigidicp). 
I've modified the code so its a bit easier to run, added some exception handling when rigidICP encounters Infs or NaNs, 
added comments (though not always useful ones), renamed most variables to something a little more readble and tried making things 
a bit more readable. The code still seems to work, albeit slowly, though that seems attributable to the very low error threshold
in rigidICP.

Description
---

The function aligns, and non-rigidly deforms a source/template mesh to a second target mesh. Isotropic meshes are preferred. 

Because of the ICP character of the technique, the function is quit slow, with large meshes taking up to 15' to run. 
nonrigidICP is the principal file to be used and requires both vertices and faces of the meshes as input
