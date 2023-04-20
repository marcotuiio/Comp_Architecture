.include "macros.asm"
.data
    vet_metade: .word 1, 2, 4, 3, 5, 7, 6, 8, 10, 9, 11, 12, 14, 13, 15, 16, 18, 17, 19, 20
    vet_oitenta: .word 2, 4, 6, 8, 10, 11, 12, 13, 14, 15, 16, 18, 20, 1, 3, 5, 7, 9, 17, 19
    vet_inverso: .word 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
    vet_aleatorio: .word 15, 9, 12, 7, 5, 2, 18, 4, 20, 6, 1, 14, 13, 8, 11, 10, 19, 16, 3, 17
.text

    main:
        print_str("\n* QuickSort é recomendado para vetores grandes e desordenados, pois possui complexidade O(n log n)\n")
        print_str("* BubbleSort é recomendado para vetores pequenos e quase ordenados, pois possui complexidade O(n^2)\n")
        print_str("* InsertionSort é recomendado para vetores pequenos e quase ordenados, pois possui complexidade O(n^2)\n")

        la $s0, vet_aleatorio
        li $s1, 20

        li $t0, 9 # flag
        loop:
            beqz $t0, end # if flag == 1, endp
            jal menu_cenarios
            beq $t0, 1, bubble_sort # metade_ordenado
            beq $t0, 2, insertion_sort # oitenta_ordenado
            beq $t0, 3, quick_sort_caller # inverso
            beq $t0, 4, quick_sort_caller # aleatorio
            beq $t0, 5, print_vet
            j loop
        end:
            terminate

    bubble_sort:
        print_str("\nPara dado cenario, bubble sort é recomendado e executado\n")
        subi $s5, $s1, 1  # $s5 = Tamanho do vetor -1 (pois são dois loops com essa condição de parada)
        li $t6, 0  # i
        loop1:
            beq $t6, $s5, end1  # Se i = tamanho do vetor -1
            li $s3, 1  # auxiliar para acessar o vet[j+1]
            li $s4, 0  # j
            
            loop2:
                beq $s4, $s5, end2	# Se j = tamanho do vetor -1
                sll $t1, $s4, 2  # Reg temp $t1 = 4*j (indice atual do vetor)
                add $t1, $t1, $s0  # Carregando em $t1 = endereço de vetor[j]
                lw $t2, 0($t1)  # $t2 = valor de vetor[j]
                
                sll $t3, $s3, 2  # Reg temp $t3 = 4*j+1 (indice atual+1 do vetor)
                add $t3, $t3, $s0  # Carregando em $t3 = endereço de vetor[j+1] 
                lw $t4, 0($t3)  # $t4 = valor de vetor[j+1]
                blt $t2, $t4, rept  # Se vetor[j] < vetor[j+1], repetir
                
                swap:
                    add $t5, $t2, 0  # $t5 = vet[j] 
                    sw $t4, 0($t1)  # vet[j] = vet[j+1], posição 0($t1) recebendo conteúdo de $t4  
                    sw $t5, 0($t3)  # vet[j+1] = vet[j], posição 0($t3) recebendo conteúdo de $t5			
                rept:
                    addi $s3, $s3, 1  # (j+1) = j+1
                    addi $s4, $s4, 1  # j = j + 1
                    j loop2
            end2:
                addi $t6, $t6, 1  # i = i + 1
                j loop1
        end1:
            j loop    

    insertion_sort:
        print_str("\nPara dado cenario, insertion sort é recomendado e executado\n")
        li $t1, 1 # i = 1
        loop_for:
            beq $t1, $s1, end_for  # Se i = tamanho do vetor, encerrar
            sub $t2, $t1, 1 # j = i - 1
            
            sll $t3, $t1, 2  # Reg temp $t3 = 4*i (indice atual do vetor)
            add $t3, $t3, $s0  # Carregando em $t3 = endereço de vetor[i]
            lw $t4, 0($t3)  # $t4 = valor de vetor[i]

            sll $t5, $t2, 2  # Reg temp $t5 = 4*j (indice atual do vetor)
            add $t5, $t5, $s0  # Carregando em $t5 = endereço de vetor[j]
            lw $t6, 0($t5)  # $t6 = valor de vetor[j]

            loop_while:
                bltz $t2, end_while  # Se j < 0, encerrar
                blt $t6, $t4, end_while

                addi $t5, $t2, 1 # $t5 = j+1
                sll $t5, $t5, 2  # Reg temp $t5 = 4*(j+1) (indice atual do vetor)
                add $t5, $t5, $s0  # Carregando em $t5 = endereço de vetor[j+1]
                sw $t6, 0($t5)  # vetor[j+1] = vetor[j]

                subi $t2, $t2, 1  # j = j - 1
                sll $t5, $t2, 2  # Reg temp $t5 = 4*j (indice atual do vetor)
                add $t5, $t5, $s0  # Carregando em $t5 = endereço de vetor[j]
                lw $t6, 0($t5)  # $t6 = valor de vetor[j]
                j loop_while
            
            end_while:
                addi $t5, $t2, 1 # $t5 = j+1
                sll $t5, $t5, 2  # Reg temp $t5 = 4*(j+1) (indice atual do vetor)
                add $t5, $t5, $s0  # Carregando em $t5 = endereço de vetor[j+1]
                sw $t4, 0($t5)  # vetor[j+1] = vetor[i]
                addi $t1, $t1, 1  # i = i + 1
                j loop_for
        end_for:
            j loop

    quick_sort_caller:
        print_str("\nPara dado cenario, quick sort é recomendado e executado\n")
        move $t0, $s0
        move $a0, $t0
        li $a1, 0   
        subi $a2, $s1, 1 # utlimo indice
        jal quicksort

        li $t0, 9
        j loop
    
    swap_quick:               #swap method
        addi $sp, $sp, -12  # Make stack room for three
        sw $a0, 0($sp)      # Store a0
        sw $a1, 4($sp)      # Store a1
        sw $a2, 8($sp)      # store a2

        sll $t1, $a1, 2     #t1 = 4a
        add $t1, $t1, $s0   #t1 = arr + 4a
        lw $s3, 0($t1)      #s3  t = array[a]

        sll $t2, $a2, 2     #t2 = 4b
        add $t2, $t2, $s0  #t2 = arr + 4b
        lw $s4, 0($t2)      #s4 = arr[b]

        sw $s4, 0($t1)      #arr[a] = arr[b]
        sw $s3, 0($t2)      #arr[b] = t 

        addi $sp, $sp, 12   #Restoring the stack size
        jr $ra          #jump back to the caller

    partition:          #partition method
        addi $sp, $sp, -16  #Make room for 5
        sw $a0, 0($sp)      #store a0
        sw $a1, 4($sp)      #store a1
        sw $a2, 8($sp)      #store a2
        sw $ra, 12($sp)     #store return address

        move $s5, $a1       #s5 = low
        move $s2, $a2       #s2 = high

        sll $t1, $s2, 2     # t1 = 4*high
        add $t1, $a0, $t1   # t1 = arr + 4*high
        lw $t2, 0($t1)      # t2 = arr[high] //pivot

        addi $t3, $s5, -1   #t3, i=low -1
        move $t4, $s5       #t4, j=low
        addi $t5, $s2, -1   #t5 = high - 1

        forloop: 
            slt $t6, $t5, $t4   #t6=1 if j>high-1, t7=0 if j<=high-1
            bne $t6, $zero, endfor  #if t6=1 then branch to endfor

            sll $t1, $t4, 2     #t1 = j*4
            add $t1, $t1, $a0   #t1 = arr + 4j
            lw $t7, 0($t1)      #t7 = arr[j]

            slt $t8, $t2, $t7   #t8 = 1 if pivot < arr[j], 0 if arr[j]<=pivot
            bne $t8, $zero, endfif  #if t8=1 then branch to endfif
            addi $t3, $t3, 1    #i=i+1

            move $a1, $t3       #a1 = i
            move $a2, $t4       #a2 = j
            jal swap_quick        #swap(arr, i, j)

            addi $t4, $t4, 1    #j++
            j forloop

            endfif:
                addi $t4, $t4, 1    #j++
                j forloop       #junp back to forloop

    endfor:
        addi $a1, $t3, 1        #a1 = i+1
        move $a2, $s2           #a2 = high
        add $v0, $zero, $a1     #v0 = i+1 return (i + 1);
        jal swap_quick            #swap(arr, i + 1, high);

        lw $ra, 12($sp)         #return address
        addi $sp, $sp, 16       #restore the stack
        jr $ra              #junp back to the caller

    quicksort:              #quicksort method
        addi $sp, $sp, -16      # Make room for 4
        sw $a0, 0($sp)          # a0
        sw $a1, 4($sp)          # low
        sw $a2, 8($sp)          # high
        sw $ra, 12($sp)         # return address

        move $t0, $a2           #saving high in t0

        slt $t1, $a1, $t0       # t1=1 if low < high, else 0
        beq $t1, $zero, endif       # if low >= high, endif

        jal partition           # call partition 
        move $s3, $v0           # pivot, s0= v0

        lw $a1, 4($sp)          #a1 = low
        addi $a2, $s3, -1       #a2 = pi -1
        jal quicksort           #call quicksort

        addi $a1, $s3, 1        #a1 = pi + 1
        lw $a2, 8($sp)          #a2 = high
        jal quicksort           #call quicksort

        endif:
            lw $a0, 0($sp)          #restore a0
            lw $a1, 4($sp)          #restore a1
            lw $a2, 8($sp)          #restore a2
            lw $ra, 12($sp)         #restore return address
            addi $sp, $sp, 16       #restore the stack
            jr $ra              #return to caller

    print_vet:
        li $t1, 0
        li $t3, 20 # tamanho
        print_str("\nVetor: ")
        loop_print:	
                beq $t3, $t1, exit  # Se tamanho máximo do vetor ja foi alcançado, encerrar
                sll $t4, $t1, 2  # Reg temp $t1 = 4*i (indice atual do vetor)
                add $t4, $t4, $s0  # Carregando em $t1 = endereço de vetor[i] 
                lw $t2, 0($t4)  # $t2 = valor de vetor[i]
                print_int($t2)
                print_str(" ")
                addi $t1, $t1, 1  # Atualizando i = i+1
                j loop_print
	    exit:
            print_str("\n")
            j loop

    menu_cenarios:
        print_str("\n1. Metade dos elementos do vetor estão ordenados\n")
        print_str("2. O vetor está quase todo (80%) ordenado\n")
        print_str("3. O vetor está na ordem inversa, ou seja, o vetor já está ordenado\n")
        print_str("4. O vetor é completamente aleatório (QUICKSORT NAO FUNCIONA AQUI)\n")
        print_str("5. Printar vetor\n")
        print_str("0. Exit\n")
        print_str(">> Enter option: ")
        scan_int($t0)
        jr $ra
