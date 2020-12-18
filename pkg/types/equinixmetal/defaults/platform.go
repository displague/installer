package defaults

import "github.com/openshift/installer/pkg/types/equinixmetal"

// Defaults for the equinixmetal platform.
const (
	// TODO(displague) what API? metadata?
	DefaultURI = "https://api.equinix.com/metal/v1"
)

// SetPlatformDefaults sets the defaults for the platform.
func SetPlatformDefaults(p *equinixmetal.Platform) {
}
