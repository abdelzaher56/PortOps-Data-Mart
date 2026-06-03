# DAX Measures Documentation

---

# Core Measures

## Total Container Moves

Counts all container movement transactions recorded in the terminal.

```DAX
Total Container Moves =
COUNTROWS ( 'Mart fact_container_movement' )
```

**Business Purpose**

* Primary throughput KPI.
* Measures terminal operational activity.
* Used as the base measure for trend and performance analysis.

---

## Avg Crane Cycle Seconds

Calculates the average crane cycle time per container move.

```DAX
Avg Crane Cycle Seconds =
DIVIDE (
    SUM ( 'Mart fact_container_movement'[crane_cycle_seconds] ),
    COUNTROWS ( 'Mart fact_container_movement' ),
    0
)
```

**Business Purpose**

* Measures crane operational efficiency.
* Helps identify equipment bottlenecks.
* Lower values indicate better crane performance.

---

## Gate Transaction Volume

Counts all gate transactions processed by the terminal.

```DAX
Gate Transaction Volume =
COUNTROWS ( 'Mart fact_gate_transaction' )
```

**Business Purpose**

* Measures overall gate activity.
* Tracks truck traffic volume through terminal gates.
* Supports gate capacity and workload analysis.

---

# Gate Performance Measures

## Avg Truck Turnaround Minutes

Calculates the average truck turnaround time.

```DAX
Avg Truck Turnaround Minutes =
AVERAGEX (
    'Mart fact_gate_transaction',
    'Mart fact_gate_transaction'[turnaround_minutes]
)
```

**Business Purpose**

* Key gate performance KPI.
* Measures the average time trucks spend inside the terminal.
* Lower turnaround times indicate more efficient gate operations.

---

## Gate-Ins Count

Counts all truck gate-in transactions.

```DAX
Gate-Ins Count =
COUNTROWS ( 'Mart fact_gate_transaction' )
```

**Business Purpose**

* Measures inbound truck traffic.
* Helps monitor gate workload.
* Used to analyze terminal entry activity.

---

## Gate-Outs Count

Counts truck gate-out transactions by activating the relationship between the Gate Out date and the Date Dimension.

```DAX
Gate-Outs Count =
CALCULATE (
    COUNTROWS ( 'Mart fact_gate_transaction' ),
    USERELATIONSHIP (
        'Mart fact_gate_transaction'[GateOutDateFK],
        'Mart dim_date'[DateKey]
    )
)
```

**Business Purpose**

* Measures outbound truck traffic.
* Enables reporting based on truck exit dates.
* Supports gate throughput and performance analysis.

**Technical Note**

`USERELATIONSHIP()` is used because the active relationship between `fact_gate_transaction` and `dim_date` is based on the Gate-In date. To analyze transactions by Gate-Out date, the inactive relationship is temporarily activated within the measure.
