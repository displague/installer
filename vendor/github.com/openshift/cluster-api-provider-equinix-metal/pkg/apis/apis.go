// Generate deepcopy for apis
//go:generate go run ../../vendor/sigs.k8s.io/controller-tools/cmd/controller-gen paths=./... object:headerFile=../../hack/boilerplate/boilerplate.go.txt,year=2020

// Package apis contains Kubernetes API groups.
package apis

import (
	"k8s.io/apimachinery/pkg/runtime"
)

// AddToSchemes may be used to add all resources defined in the project to a Scheme
var AddToSchemes runtime.SchemeBuilder

// AddToScheme adds all Resources to the Scheme
func AddToScheme(s *runtime.Scheme) error {
	return AddToSchemes.AddToScheme(s)
}
