.include "macros.asm"

.data 
    list_1: .word 12, 0, 0 # word size, number of elements, head
    list_2: .word 12, 0, 0 # word size, number of elements, head
    list_n: .word 12, 0, 0 # word size, number of elements, head
    node: .word 12, 0, 0 # word size, info, next 
.text

    main:
        print_str("Linked list in MIPS\n")

        la $s1, list_1 # load address of list1
        jal create_list_1

        la $s2, list_2 # load address of list2
        jal create_list_2

        la $s4, node # load address of node      
        
        li $t0, 9 # flag
        loop:
            beqz $t0, end # if flag == 1, end
            jal menu
            beq $t0, 1, create_node
            beq $t0, 2, print_list
            beq $t0, 3, delete_node
            beq $t0, 4, find_index
            beq $t0, 5, merge
            beq $t0, 6, divide
            beq $t0, 7, copy
            beq $t0, 8, ascending
            beq $t0, 9, descending
            j loop
        end:
            terminate
    
    create_list_1:
        lw $a0, 0($s1) # load word size
        calloc($a0, $s1)
        jr $ra
    
    create_list_2:
        lw $a0, 0($s2) # load word size
        calloc($a0, $s2)
        jr $ra

    create_list_n:
        lw $a0, 0($s6) # load word size
        calloc($a0, $s6)
        jr $ra

    create_node:
        jal choose_list
        
        lw $a0, 0($s4) # load word size
        calloc($a0, $s3)
        print_str("\nEnter info to add: ")
        scan_int($t2)

        sw $t2, 4($s3) # node->info = info
        sw $zero, 8($s3) # node->next = null

        lw $t1, 8($s0) # load head
        beqz $t1, first_node # if head == null, first_node

        traverse:
            lw $t2, 8($t1) # load next
            beqz $t2, save_node # if next == null, plus
            next_node:
                move $t1, $t2 # previous = next
                j traverse
            save_node:
                sw $s3, 8($t1) # previous->next = node
                j plus

        first_node:
            sw $s3, 8($s0) # head = node
        plus:
            lw $t2, 4($s0) # load size
            addi $t2, $t2, 1 # size++
            sw $t2, 4($s0) # list->size = size
        j loop

    print_list:
        jal choose_list

        lw $t2, 8($s0) # load head
        beqz $t2, loop # if head == null, loop
        print_str("\nList: ")
        print_loop:
            lw $t3, 4($t2) # load info
            print_int($t3)
            print_str(" ")
            lw $t2, 8($t2) # load next
            bnez $t2, print_loop
        print_str("\n")
        j loop

    print_all:
        li $t1, 0
        loop_vetor:
            beq $t1, $s7, loop
            sll $t2, $t1, 2
            add $t2, $t2, $s5
            lw $t4, 0($t2)  # $t4 é uma lista
            print_str("k-List ")
            print_int($t1)
            print_str(": ")
            lw $t4, 8($t4) # head current list
            loop_prints:
                lw $t5, 4($t4) # value current node
                print_int($t5)
                print_str(" ")
                lw $t4, 8($t4) # next
                bnez $t4, loop_prints
                print_str("\n")
                addi $t1, $t1, 1
                j loop_vetor

    delete_node:
        jal choose_list

        print_str("\nEnter info to be deleted: ")
        scan_int($t2)

        lw $t1, 8($s0) # load head
        beqz $t1, loop # if head == null, loop
        remove_loop:
            lw $t3, 4($t1) # load current info
            beq $t2, $t3, remove
            move $t4, $t1 # save previous
            lw $t1, 8($t1) # load next
            bnez $t1, remove_loop
            print_str("\nInfo not found\n")
            j loop
            remove:
                print_str("\nNode found: ")
                print_int($t3)
                # t1 = current to be removed
                # t4 = previous
                lw $t5, 8($s0) # load head
                bne $t1, $t5, not_head # if current == head, remove_head
                if_head:
                    lw $t5, 8($t1) # load next
                    sw $t5, 8($s0) # head = next
                    lw $zero, 0($t1) 
                    j minus
                not_head:    
                    lw $t5, 8($t1) # load next
                    sw $t5, 8($t4) # previous->next = next
                minus:
                    lw $t1, 4($s0) # load word size
                    subi $t1, $t1, 1
                    sw $t1, 4($s0) # list->size--
                print_str("\nNode removed\n")
                j loop

    find_index:
        jal choose_list

        print_str("\nEnter info to find index: ")
        scan_int($t2)
        
        lw $t1, 8($s0) # load head
        beqz $t1, loop # if head == null, loop
        li $t5, 0
        looking_loop:
            lw $t3, 4($t1) # load current info
            beq $t2, $t3, found
            move $t4, $t1 # save previous
            lw $t1, 8($t1) # load next
            addi $t5, $t5, 1
            bnez $t1, looking_loop
            print_str("\nInfo not found\n")
            j loop
            found:
                print_str("\nNode found ")
                print_int($t3)
                print_str(" in index ")
                print_int($t5)
                print_str("\n")
                j loop

    merge:
        print_str("\nMerging list 2 into 1\n")
        move $s0, $s1 # list 1

        lw $t1, 8($s0) # load head
        beqz $t1, loop # if head == null, loop  

        lw $t2, 8($s2) # load head
        traverse_list2:
            lw $t3, 4($t2) # load info
            lw $a0, 0($s4) # load word size
            calloc($a0, $s3)

            sw $t3, 4($s3) # node->info = info
            sw $zero, 8($s3) # node->next = null    
            lw $t3, 8($t2) # load next
        
        merge_loop:
            lw $t2, 8($t1) # load next da lista 1
            beqz $t2, save_merge # if next == null, plus
            next_node_1:
                move $t1, $t2 # previous = next
                j merge_loop
            save_merge:
                sw $s3, 8($t1) # previous->next = node
                lw $t2, 4($s0) # load size
                addi $t2, $t2, 1 # size++
                sw $t2, 4($s0) # list->size = size
                move $t2, $t3 # previous = next
                beqz $t3, loop # if next == null, loop
                j traverse_list2

    divide:
        jal choose_list
        print_str("\n k-lists: ")
        scan_int($t2)
        move $s7, $t2

        lw $t1, 4($s0) # size
        div $t1, $t2
        mfhi $t1
        mflo $t3 # qntd de elemento por lista
        beqz $t1, oook
        addi $t3, $t3, 1 # se resto nao é zero, as listas terao tamanhos diferentes
        oook:
            beqz $t3, loop
        
        mul $t4, $t2, 4
        calloc($t4, $s5) # $s5 vetor de listas
        li $t4, 0
        lw $t1, 8($s0) # head original
        next_list:
            la $s6, list_n 
            jal create_list_n
            sll $t2, $t4, 2
            add $t2, $t2, $s5
            sw $s6, 0($t2)
            addi $t4, $t4, 1

            loop_div:
                lw $t2, 4($t1) # valor node
                lw $a0, 0($s4) # load word size
                calloc($a0, $s3)
                sw $t2, 4($s3) # node->info = info
                sw $zero, 8($s3) # node->next = null

                lw $t2, 8($s6) # load head sub list
                beqz $t2, first_node_div # if head == null, first_node
                traverse_div:
                    lw $t5, 8($t2) # load next
                    beqz $t5, save_node_div # if next == null, plus
                    next_node_div:
                        move $t2, $t5 # previous = next
                        j traverse_div
                    save_node_div:
                        sw $s3, 8($t2) # previous->next = node
                        j plus_div
                first_node_div:
                    sw $s3, 8($s6) # head = node
                plus_div:
                    lw $t6, 4($s6) # load size
                    addi $t6, $t6, 1 # size++
                    sw $t6, 4($s6) # list->size = size

                lw $t1, 8($t1)
                beqz $t1, print_all
                beq $t6, $t3, next_list
                j loop_div

    copy:
        print_str("\nCopying list 2 into 1\n")

        lw $t1, 8($s1) # load head1
        lw $t2, 8($s2) # load head2
        copy_loop:
            beqz $t2, loop # se lista 2 == null, loop
            lw $t3, 4($t2) # carregando info node atual lista 2
            beqz $t1, criar_node # se lista 1 == null, criar node

            sw $t3, 4($t1) # salvando info atual da lista 2 no node atual da lista 1
            j next_copy

            criar_node:
                lw $a0, 0($s4) # carregando word size
                calloc($a0, $s3) # alocando node
                sw $t3, 4($s3) # salvando info da lista 2 no novo node
                sw $zero, 8($s3) # salvando null no next node
                
                plus_copy:
                    lw $t7, 4($s1) # load size
                    addi $t7, $t7, 1 # size++
                    sw $t7, 4($s1) # list->size = size
                
                lw $t5, 8($s1) # carregando head
                bnez $t5, save_copy # se head == null, criar head
                sw $s3, 8($s1) # salvando novo node como head   
                move $t1, $s3
                j next_copy
                save_copy:
                    sw $s3, 8($t6)
                    move $t1, $s3

            next_copy:
                move $t6, $t1 # salvando prev
                lw $t1, 8($t1) # carregando next node lista 1
                lw $t2, 8($t2) # carregando next node lista 2
                j copy_loop

        j loop

    ascending:
        jal choose_list
        print_str("\nSorting list in ascending order\n")

        lw $t1, 8($s0) # load head
        beqz $t1, loop

        lw $t2, 4($s0) # size
        subi $t2, $t2, 1 # flag 
        li $t3, 0 # i
        lp1:
            beq $t3, $t2, end1
            lw $t1, 8($s0)
            li $t4, 0 # j
            lp2:
                beq $t4, $t2, end2
                lw $t5, 4($t1) # vet[j]
                lw $t6, 8($t1) # next 
                lw $t7, 4($t6) # vet[j+1]
                blt $t5, $t7, rept1 # if vet[j] < vet[j+1], NEXT
                swap1:
                    sw $t7, 4($t1) # vet[j] = valor vet[j+1]
                    sw $t5, 4($t6) # vet[j+1] = valor vet[j]
                rept1:
                    lw $t1, 8($t1)
                    addi $t4, $t4, 1
                    j lp2
            end2:
                addi $t3, $t3, 1
                j lp1
        end1:
            j loop

    descending:
        jal choose_list
        print_str("\nSorting list 1 in descending order\n")
        lw $t1, 8($s0) # load head
        beqz $t1, loop

        lw $t2, 4($s0) # size
        subi $t2, $t2, 1 # flag 
        li $t3, 0 # i
        lp11:
            beq $t3, $t2, end11
            lw $t1, 8($s0)
            li $t4, 0 # j
            lp22:
                beq $t4, $t2, end22
                lw $t5, 4($t1) # vet[j]
                lw $t6, 8($t1) # next 
                lw $t7, 4($t6) # vet[j+1]
                bgt $t5, $t7, rept11 # if vet[j] < vet[j+1], NEXT
                swap11:
                    sw $t7, 4($t1) # vet[j] = valor vet[j+1]
                    sw $t5, 4($t6) # vet[j+1] = valor vet[j]
                rept11:
                    lw $t1, 8($t1)
                    addi $t4, $t4, 1
                    j lp22
            end22:
                addi $t3, $t3, 1
                j lp11
        end11:
            j loop

    print_size:
        jal choose_list

        lw $t2, 4($s0) # load size
        print_str("\nSize: ")
        print_int($t2)
        print_str("\n")
        j loop

    choose_list:
        print_str("\nWhich list? (1 or 2): ")
        scan_int($t7)
        beq $t7, 2, list2
        list1:
            move $s0, $s1
            jr $ra
        list2:
            move $s0, $s2
            jr $ra

    menu:
        print_str("\n1. Add node\n")
        print_str("2. Print list\n")
        print_str("3. Delete node\n")
        print_str("4. Find element index\n")
        print_str("5. Concatenate lists\n")
        print_str("6. Divide list\n")
        print_str("7. Copy list 2 into 1\n")
        print_str("8. Sort list ascending order\n")
        print_str("9. Sort list descending order\n")
        print_str("0. Exit\n")
        print_str(">> Enter option: ")
        scan_int($t0)
        jr $ra