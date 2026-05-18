package types

import (
	"fmt"
	"strconv"
)

// Decimal accepts JSON numbers and quoted decimal strings ("1.00" or 1.0).
type Decimal float64

func (d *Decimal) UnmarshalJSON(data []byte) error {
	s := string(data)
	if len(s) >= 2 && s[0] == '"' && s[len(s)-1] == '"' {
		s = s[1 : len(s)-1]
	}
	v, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return fmt.Errorf("Decimal: cannot parse %q: %w", string(data), err)
	}
	*d = Decimal(v)
	return nil
}

func (d Decimal) Float64() float64 { return float64(d) }
