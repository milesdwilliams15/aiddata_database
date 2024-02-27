# aiddata_database

The goal of this repository is to create a set of tools to allow easy access to datasets relevant to foreign aid research within R. At the moment, I can read in AidData core release data (version 3.1) at the level of:

- donor-recipient-years
- donor-recipient-sector-years
- donor-recipient-purpose-years

## How to use

To access the tools to do so, all you need to do is run the following line of code in R. It will run source code housed in the "_code" folder in this repository for reading in the above datasets from my Google Drive. 

```
source("http://tinyurl.com/aiddatadownloads")
```

The three main functions are:

- `get_aiddata(level = c("total", "sector", "purpose"), subset_years = NULL)`: Reads in AidData at one of three possible levels of aggregation. `level = "total"` gives you totals at the donor-recipient-year level. `level = "sector"` does the same but also breaks it down by sectors. `level = "purpose"` does the same but also breaks it down by purpose. Values returned are for all rows in the data for which aid commitments are non-zero.
- `view_codes()`: Lets you see all the aid sector and purpose codes in a tidy data frame.
- `add_full_dyads()`: Expands the dataset to include all possible donor-recipient dyads per year (and per sector or purpose if applicable). This expands the data to the true set of possible donor-recipient pairs in a given year for which a donor could have given a repipient aid but did not.

There are some other functions that are just helpers for the main `get_aiddata()` function. 

Once you've run the source code above, to access the available datasets, you can write any one of the following:

```
## access donor-recipient-year totals
data <- get_aiddata()

## access sector-level data
data <- get_aiddata(level = "sector")

## access purpose-level data
data <- get_aiddata(level = "purpose")

## take a dataset and expand to all possible dyads
data <- get_aiddata() |>
   add_full_dyads()
```

If for some reason you'd like to subset your analysis to a single year or range of years, you can do so with the `subset_years` option. Say you want all available data from 2000 onward. You would write:

```
data <- get_aiddata(subset_years = 2000:2013)
```

## Data values

Each dataset has the following columns:

- `donor`: Donor organization or country name
- `recipient`: Recipient name
- `ccode_d`: CoW code for donor countries. 
- `gwcode_d`: Gletisch-Ward code for donor countries
- `isocode_d`: ISO-3 code for donor countries
- `ccode_r`: CoW code for recipient countries
- `gwcode_r`: Gletisch-Ward code for recipient countries
- `isocode_r`: ISO-3 code for recipient countries
- `commitments_2011_constant`: sum of aid commitments in 2011 constant USD

Some things to note: 

- There should be no missing values for aid commitments, because the AidData dataset only reports donor-recipient years for which aid was committed. 
- There are a couple of donors for which year = 9999 (missing). Be sure to adjust for this if necessary.
- CoW, GW, and ISO codes are not available for all recipients and donors because some are non-state actors. If you want to study only sets of country pairs, you can simply filter out NA values for one of the three different country codes, each of which defines the scope of country actors using unique criteria. For example, filtering out NAs for the `ccode_d` and `ccode_r` columns will leave you with a donor-recipient dataset for all states in the world that are donors/recipients according to the Correlates of War state system.

## Different levels of aggregation

Depending on the level of aggregation, the data will also have additional columns. If you select `level = "sector"` the data will include:

- `crs_sector_code`: Creditor Reporting System (CRS) sector code
- `crs_sector_name`: CRS name

Furthermore, the `commitments_2011_constant` column will equal the total aid committed by a donor to a recipient per aid sector.

If you select `level = "sector"` the data will include:

- `crs_purpose_code`: CRS purpose code
- `crs_purpose_name`: CRS purpose name

For this data, `commitments_2011_constant` will equal the total aid committed by a donor to a recipient for a particular purpose.

## How the data were constructed

You can see the details of how I constructed these datasets by checking out this document I created here: [01_aiddata_cleaning.pdf](https://github.com/milesdwilliams15/aiddata_database/blob/main/_code/01_aiddata_cleaning.pdf).

If you notice any errors or have any suggestions, email me at williamsmd@denison.edu.

## Other helpful resources

For project level data, several years ago someone created an API for R users to pull this data. You can check it out at this link here: https://github.com/felixhaass/aiddata/tree/master