# Profit Leakage & True Unit Economics Analysis

## Overview
This project analyzes true unit economics and profit leakage for an e-commerce business using transactional data.
The goal is to move beyond revenue and blended averages and identify where profitability is actually created or diluted.

The analysis is designed as an internal, decision-support dashboard rather than a tutorial-style project.

---

## Business Questions Addressed
- Where does profit go after all operational and acquisition costs?
- Are any product categories structurally less profitable?
- Is profitability evenly distributed across customers?

---

## Key Insights
- Overall profitability remains stable under both blended and aggressive CAC assumptions.
- Logistics and fulfillment costs are the dominant drivers of margin variation.
- Customer profitability is highly uneven, with a small subset contributing disproportionately to total value.

---

## Tech Stack
- SQL (PostgreSQL) – data modeling and unit economics logic
- Power BI – semantic modeling and executive dashboards
- DAX – profit calculations and CAC stress testing

---

## Repository Structure
- sql/ → Data modeling and unit economics logic
- data raw/ → data
- powerbi/ → Power BI dashboard
- screenshots → Dashboard previews
- report/ → Executive summary

---

## Dashboard Preview

### Unit Economics Overview
![Unit Economics Overview](screenshots/page1_unit_economics_overview.png)

### Category Profitability Diagnosis
![Category Profitability](screenshots/page2_category_profitability.png)

### Customer Profitability Analysis
![Customer Profitability](screenshots/page3_customer_profitability.png)

---

## Notes
- CAC values are understated due to dataset limitations.
- Insights should be interpreted as directional rather than absolute benchmarks.

---

## 🙌 Author
This project was designed as a **real-world, business-focused analytics case study** for startup and SME environments, demonstrating practical decision-driven data analysis instead of surface-level dashboards.

---

<p align="center">
  <b>Built by Mohsin  (Data Analyst)</b><br>
  📧 mohsinansari1799@email.com &nbsp;|&nbsp;
  🔗 <a href="https://www.linkedin.com/in/mohsinraza-data/">LinkedIn Profile</a>
</p>
