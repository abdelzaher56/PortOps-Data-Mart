# DAX Measures Documentation

**Project:** PortOps Terminal Analytics Dashboard

---

# Core Measures

## Total Container Moves

Counts all container movement transactions recorded in the terminal.

```DAX
Total Container Moves =
COUNTROWS ( 'Mart fact_container_movement' )
```

**Business Purpose**

* Primary operational throughput KPI.
* Used to monitor terminal activity and productivity.
* Serves as a base measure for trend and YoY analysis.

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
* Lower values indicate faster handling performance.
* Helps identify equipment bottlenecks and productivity issues.

---

## Gate Transaction Volume

Counts all gate transactions processed by the terminal.

```DAX
Gate Transaction Volume =
COUNTROWS ( 'Mart fact_gate_transaction' )
```

**Business Purpose**

* Measures overall gate activity.
* Used to track truck traffic volume.
* Supports gate capacity and resource planning.

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

* Key service-level KPI.
* Measures gate efficiency from truck entry to exit.
* Lower turnaround times improve customer satisfaction and reduce congestion.

---

## Gate-Ins Count

Counts all truck gate-in transactions.

```DAX
Gate-Ins Count =
COUNTROWS ( 'Mart fact_gate_transaction' )
```

**Business Purpose**

* Measures inbound truck traffic.
* Supports gate workload analysis.
* Used alongside Gate-Out metrics for flow monitoring.

---

## Gate-Outs Count

Counts truck gate-out transactions using the inactive Gate Out relationship.

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
* Enables accurate reporting based on truck exit date.
* Supports gate performance and throughput analysis.

---

# Vessel & Operational Performance Measures

## Berth Delay Avg Hours

Calculates the average berth delay duration.

```DAX
Berth Delay Avg Hours =
AVERAGE ( 'Mart fact_vessel_call'[berth_delay_hours] )
```

**Business Purpose**

* Measures vessel scheduling efficiency.
* Identifies operational delays at berth allocation.
* Supports service-level monitoring and planning improvements.

---

## Moves Variance %

Measures the variance between actual and planned vessel moves.

```DAX
Moves Variance % =
DIVIDE (
    SUM ( 'Mart fact_vessel_call'[moves_variance] ),
    SUM ( 'Mart fact_vessel_call'[total_moves_planned] ),
    0
)
```

**Business Purpose**

* Evaluates execution performance against operational plans.
* Positive values indicate over-performance.
* Negative values indicate under-performance.

---

# Time Intelligence Measures

## Moves 7-Day Rolling Avg

Calculates the rolling 7-day average of container moves.

```DAX
Moves 7-Day Rolling Avg =
AVERAGEX (
    DATESINPERIOD (
        'Mart dim_date'[FullDate],
        LASTDATE ( 'Mart dim_date'[FullDate] ),
        -7,
        DAY
    ),
    [Total Container Moves]
)
```

**Business Purpose**

* Smooths daily operational fluctuations.
* Helps identify underlying throughput trends.
* Useful for operational forecasting and performance monitoring.

---

## Moves YoY %

Calculates Year-over-Year growth in container moves.

```DAX
Moves YoY % =
VAR CurrentMoves =
    [Total Container Moves]

VAR PreviousMoves =
    CALCULATE (
        [Total Container Moves],
        SAMEPERIODLASTYEAR ( 'Mart dim_date'[FullDate] )
    )

RETURN
    DIVIDE (
        CurrentMoves - PreviousMoves,
        PreviousMoves,
        0
    )
```

**Business Purpose**

* Measures annual growth or decline in terminal activity.
* Supports executive-level performance reporting.
* Enables long-term operational trend analysis.

---

## Turnaround Bucket

Classifies truck turnaround time into performance bands to support operational segmentation and SLA analysis.

```DAX id="tbk001"
Turnaround Bucket =
SWITCH (
    TRUE(),
    'Mart fact_gate_transaction'[turnaround_minutes] < 30, "0-30",
    'Mart fact_gate_transaction'[turnaround_minutes] < 60, "30-60",
    'Mart fact_gate_transaction'[turnaround_minutes] < 90, "60-90",
    "90+"
)
```

**Business Purpose**

* Segments gate transactions based on service time performance.
* Helps identify congestion levels and operational efficiency tiers.
* Useful for SLA reporting and bottleneck analysis.

**Interpretation**

* `0–30 min` → Excellent turnaround performance
* `30–60 min` → Acceptable operational range
* `60–90 min` → Delayed processing
* `90+ min` → Severe congestion / inefficiency



**Technical Note**

`USERELATIONSHIP()` is used because the active relationship between `fact_gate_transaction` and `dim_date` is based on the Gate-In date. To analyze transactions by Gate-Out date, the inactive relationship is temporarily activated within the measure.
