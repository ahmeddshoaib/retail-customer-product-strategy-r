# Retail Customer & Product Strategy in R

This project combines customer value, behavioural segmentation and product-design analysis to identify a target segment and evaluate the attributes of a proposed coffee product.

The submitted MSc project combined RFM analysis, clustering, prospect classification, conjoint analysis, market-share simulation and PCA. The GitHub version focuses on the strongest commercial methods and uses synthetic data because the four university source files are unavailable.

## Commercial problem

A retail product decision has several layers: identify the customers worth serving, understand the attributes they value, position the concept against alternatives and decide how much confidence to place in a simulated preference share. This project connects those layers instead of treating segmentation, conjoint and positioning as unrelated techniques.

## What I built

I created customer-level recency, frequency and monetary measures, compared a four-cluster behavioural solution, interpreted the target segment, estimated conjoint part-worths and attribute importance, simulated concept preference and used PCA to map competitive positioning. The public rebuild turns that sequence into one reproducible R workflow with exported customer and product decision tables.

## Historical project evidence

The submitted analysis covered **925 customers** and reported:

- total revenue of **£101,728.60**;
- coffee revenue of **£16,154.17**;
- a four-segment customer solution;
- conjoint importance led by format at **44.5%** and price at **31.1%**;
- a simulated **32.0%** share for the proposed concept.

Those figures remain archived academic results. All public outputs in this repository carry a `synthetic_demo` label and should not be read as real retailer performance.

![Synthetic segment profile](figures/rfm_segment_profile.png)

## Decision flow

```text
transaction history
      |
      v
RFM customer value + four behavioural clusters
      |
      v
target segment definition
      |
      +--> conjoint part-worths and attribute importance
      +--> concept utility and share simulation
      `--> PCA competitive positioning
      |
      v
evidence-based product, price, channel and promotion choices
```

## Changes made for public release

- Separates exploratory segmentation from predictive claims.
- Removes the weak LDA headline: the submitted classifier achieved no meaningful lift over the null rate.
- Provides one reproducible run instead of a long monolithic script.
- Exports customer-level RFM and segment assignments.
- Keeps conjoint design, coefficients and attribute importance traceable.
- Labels simulated market share as a preference scenario rather than a sales forecast.

These changes sharpen the decision claim. The analysis can identify a plausible segment and product configuration, but a launch decision would still require concept testing, cost and margin data, distribution feasibility and a controlled market trial.

![Synthetic conjoint importance](figures/conjoint_importance.png)

## Repository guide

| Path | Purpose |
|---|---|
| `R/generate_demo_data.R` | Synthetic transactions, conjoint responses and product profiles |
| `R/run_analysis.R` | RFM, clustering, conjoint, simulation and PCA |
| `outputs/` | Customer and product decision tables |
| `figures/` | Segment and product visuals |
| `tests/validate_results.R` | Grain and reconciliation checks |

## Run it

```bash
Rscript requirements.R
Rscript R/generate_demo_data.R
Rscript R/run_analysis.R
Rscript tests/validate_results.R
```

## Limitations

RFM clusters describe observed purchasing patterns; they do not prove future response. Conjoint utilities come from stated preferences and are sensitive to design and sample quality. The market-share output is a controlled preference simulation, not a commercial forecast.

## Author

**Muhammad Ahmed Shoaib**<br>
Retail analytics, customer segmentation and commercial decision support.
