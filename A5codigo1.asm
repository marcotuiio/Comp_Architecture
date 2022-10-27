.include "macros.asm"

.data
	alfabeto: .word A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z  # Declarando ALFABETO 
	size: 26  # Declarando tamanho do vetor
.word

main:
	print_str("\nInforme chave N positiva e menor ou igual a 26: ")
	scan_int($s0)