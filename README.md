# Bridge Conversion scripts

This repository contains scripts to convert various [contract bridge](https://en.wikipedia.org/wiki/Contract_bridge) data between formats.

## Scripts

- `tc-cbs-indiv`, `tc-cbs-pairs`, `tc-cbs-teams`  
   convert from [Tournament Calculator](https://tournamentcalculator.com) presentation to format suitable for import into [MatrikaCBS](https://matrikacbs.cz)
- `getMatrikaCBScsv.php` a server script that fetches players.csv from MatrikaCBS,
   converts it to UTF8 and maps columns so that the file can be used by Tournament 
   Calculator
