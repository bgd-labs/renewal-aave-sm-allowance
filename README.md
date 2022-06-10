# :ghost: Renewal Aave Safety Module Allowance
This repository the payload and tests for the periodic update of the allowance of AAVE from the Aave Ecosystem's Reserve to the 2 main components of the Aave Safety Module: stkAAVE and stkABPT

- Proposal payload: [AllowanceRenewalSMPayload](./src/AllowanceRenewalSMPayload.sol)
- Tests: [ValidationRenewalAllowanceSM](./src/test/ValidationRenewalAllowanceSM.sol)

<br>
<br>

### Dependencies

```
make update
```

### Compilation

```
make build
```

### Testing

```
make test
```