## 2nd Resubmission
* Updated year in License from 2019 to 2020  
* Removed examples for unexported functions  
* Wrapped examples requiring token in \donttest instead of \dontrun  
* Fixed minor spacing issue in description 

## Resubmission

I have fixed the following issues as per comments for the last submission.

* Fixed authors field - changed 'Author' field to 'Authors@R'  
* Fixed description - corrected spelling errors, added web links, elaborated on package functionality  
* Removed examples for unexported functions  
* Regarding the removal of 'donttest' around examples: All functions require an API key hence there is currently no way of providing examples without wrapping them in donttest. Although some examples will print errors, functions currently have error handling and should return an output; hence they are wrapped in 'donttest' instead of 'dontrun'. 
