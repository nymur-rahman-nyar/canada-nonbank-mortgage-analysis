import pandas as pd
import matplotlib.pyplot as plt

INPUT_CSV = "processed_sql_data/nonbank_delinquency_rates.csv"
OUT1 = "res/delinquency_rates.png"
OUT2 = "res/severe_delinquency_over90.png"

df = pd.read_csv(INPUT_CSV, parse_dates=["date"]).sort_values("date")

# chaart 4: total delinquency rate (all arrears) # insured vs uninsured
plt.figure()
plt.plot(df["date"], df["insured_delinquency_rate_pct"], label="Insured delinquency rate (%)")
plt.plot(df["date"], df["uninsured_delinquency_rate_pct"], label="Uninsured delinquency rate (%)")
plt.title("Non-bank mortgage delinquency rates (arrears / outstanding)")
plt.xlabel("Date")
plt.ylabel("Delinquency rate (%)")
plt.legend()
plt.tight_layout()
plt.savefig(OUT1, dpi=300)
plt.close()

# Chart 5: severe delinquency (oover 90 days)  ###  insured vs uninsured
plt.figure()
plt.plot(df["date"], df["insured_over90_rate_pct"], label="Insured over-90-days rate (%)")
plt.plot(df["date"], df["uninsured_over90_rate_pct"], label="Uninsured over-90-days rate (%)")
plt.title("Severe delinquency (over 90 days) — non-bank mortgages")
plt.xlabel("Date")
plt.ylabel("Over-90-days rate (%)")
plt.legend()
plt.tight_layout()
plt.savefig(OUT2, dpi=300)
plt.close()

print(f"Saved: {OUT1}")
print(f"Saved: {OUT2}")
