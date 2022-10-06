.include "macros.asm"

.data
	vet: .space 256
.text

main:
	li $s0, 5
	li $s5, 8
	scan_array(vet,$s0)
	print_array(vet, $s0)
	print_str("\nSORTED?\n")
	sort_array(vet, $s0)
	print_array(vet, $s0)
	terminate
