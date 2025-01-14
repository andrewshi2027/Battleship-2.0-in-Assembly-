.data
space: .asciiz " "    # Space character for printing between numbers
newline: .asciiz "\n" # Newline character
extra_newline: .asciiz "\n\n" # Extra newline at end

.text
.globl zeroOut 
.globl place_tile 
.globl printBoard 
.globl placePieceOnBoard 
.globl test_fit 



# Function: zeroOut
# Arguments: None
# Returns: void
zeroOut:
    # Function prologue
    addi $sp, $sp, -4 
    sw $ra, 0($sp)

    # Initialize variables
    la $t0, board               # Load address of board
    lw $t1, board_width         # Load number of columns
    lw $t2, board_height        # Load number of rows
    li $t3, 0                   # index = 0

zeroOut_outer: 
    bge $t3, $t2, zero_done     # if row index >= board_height, exit outer loop
    li $t4, 0                   # column index = 0

zeroOut_inner: 
    bge $t4, $t1, next_row      # If all columns are done, go next row
    mul $t5, $t3, $t1           # row offset = row index * number of columns
    add $t6, $t5, $t4           # array index = row offset + column index
    add $t7, $t0, $t6           # memory address of board element
    sb $0, 0($t7)               # Set board[index] to 0

    addiu $t4, $t4, 1           # column index + 1
    j zeroOut_inner             # Jump back to process the next column

next_row:
    addi $t3, $t3, 1            # Increment Row Index
    j zeroOut_outer             # Continue outer loop

zero_done:
    # Function epilogue
    lw $ra, 0($sp)              # Restore stack address 
    addiu $sp, $sp, 4           # Deallocate stack space
    jr $ra                      # Return





# Function: placePieceOnBoard
# Arguments: 
#   $a0 - address of piece struct
#   $a1 - ship_num
placePieceOnBoard:
    # Function prologue
    addiu $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s7, 4($sp)

    li $s2, 0
    
    # Load piece fields
    lw $s3, 0($a0)              # Load type
    move $s1, $a1               # Load ship_num
    lw $s4, 4($a0)              # Load orientation
    lw $s5, 8($a0)              # Load row location
    lw $s6, 12($a0)             # Load col location

    # Return values
    li $t8, 0                   # 0: success
    li $t9, 1                   # 1: occupied
    li $s7, 2                   # 2: out of bounds

    # First switch on type
    li $t0, 1
    beq $s3, $t0, piece_square
    li $t0, 2
    beq $s3, $t0, piece_line
    li $t0, 3
    beq $s3, $t0, piece_reverse_z
    li $t0, 4
    beq $s3, $t0, piece_L
    li $t0, 5
    beq $s3, $t0, piece_z
    li $t0, 6
    beq $s3, $t0, piece_reverse_L
    li $t0, 7
    beq $s3, $t0, piece_T
    j piece_done       # Invalid type

place_success:
    lw $s7, 4($sp)
    lw $ra, 0($sp)
    addiu $sp, $sp, 8
    jr $ra

place_occupied:
    jal zeroOut
    lw $s7, 4($sp)
    lw $ra, 0($sp)
    addiu $sp, $sp, 8
    jr $ra

place_out:
    jal zeroOut
    # li $v0, 2
    lw $s7, 4($sp)
    lw $ra, 0($sp)
    addiu $sp, $sp, 8
    jr $ra

another_one:
    jal zeroOut
    # li $v0, 2
    lw $s7, 4($sp)
    lw $ra, 0($sp)
    addiu $sp, $sp, 8
    jr $ra

piece_done:

    move $v0, $s2
    beq $v0, $t8, place_success       # 0
    beq $v0, $t9, place_occupied      # 1
    beq $v0, $s7, place_out           # 2
    li $t8, 3
    beq $v0, $t8, another_one

    lw $s7, 4($sp)
    lw $ra, 0($sp)
    addiu $sp, $sp, 8
    jr $ra






# Function: printBoard
# Arguments: None (uses global variables)
# Returns: void
# Uses global variables: board (char[]), board_width (int), board_height (int)

printBoard:
    # Function prologue
    addiu $sp, $sp, -4          # Allocate stack space
    sw $ra, 0($sp)              # Save return address

    #Initialize variables
    la $t0, board               # Load address of board
    lw $t1, board_width         # Load number of columns
    lw $t2, board_height        # Load number of rows
    li $t3, 0                   # row index = 0

printBoard_outer:
    bge $t3, $t2, done          # if row index >= board_height, exit outer loop
    li $t4, 0                   # column index = 0

printBoard_inner:
    bge $t4, $t1, printBoard_next_row      
    mul $t5, $t3, $t1           # row offset = row index * number of columns
    add $t6, $t5, $t4           # array index = row offset + column index
    add $t7, $t0, $t6           # memory address of board element
    lb $a0, 0($t7)              # Load current board element
    li $v0, 11                  # Set syscall code for printing character
    addi $a0, $a0, '0'          # Convert number to ASCII character
    syscall                     # Print character
    li $v0, 11                  # Set syscall code for printing space
    li $a0, ' '                 # Space character
    syscall                     # Print the space

    addi $t4, $t4, 1            # column index + 1
    j printBoard_inner          # Jump back to process the next column

printBoard_next_row:
    li $v0, 11                  # Set syscall code for printing newline
    li $a0, '\n'                # Load newline character
    syscall                     # Print the space
    addiu $t3, $t3, 1           # Increment row index
    j printBoard_outer          # Jump back to process the next row

done:
    # Function epilogue
    lw $ra, 0($sp)              # Restore return address
    addiu $sp, $sp, 4           # Deallocate Stack Space
    jr $ra                      # Return





# Function: place_tile
# Arguments: 
#   $a0 - row
#   $a1 - col
#   $a2 - value
# Returns:
#   $v0 - 0 if successful, 1 if occupied, 2 if out of bounds
# Uses global variables: board (char[]), board_width (int), board_height (int)

place_tile:

    addiu $sp, $sp, -4          # Allocate stack space
    sw $ra, 0($sp)              # Save return address

    # Check if row or column is out of bounds
    lw $t0, board_width         # Load board_width
    lw $t1, board_height        # Load board_height
    bge $a0, $t1, p_out           # If row >= board_height
    bge $a1, $t0, p_out           # If column >= board_width

    # Calculate index in row-major order
    mul $t2, $a0, $t0           # t2 = row * board_width
    add $t2, $t2, $a1           # t2 = row * board_width + column
    la $t3, board               # Load base address of board
    add $t3, $t3, $t2           # t3 = address of board[index]

    # Check if cell is occupied
    lb $t4, 0($t3)              # Load board[index]
    bne $t4, $0, p_occupied       # If board[index] != 0

    # Place value on the board
    sb $a2, 0($t3)              # Set board[index] = value
    li $v0, 0                   # Return 0
    lw $ra, 0($sp)              # Restore return address
    addiu $sp, $sp, 4           # Deallocate Stack Space
    jr $ra

p_occupied:
    li $v0, 1                   # Return 1 (occupied)
    lw $ra, 0($sp)              # Restore return address
    addiu $sp, $sp, 4           # Deallocate Stack Space
    jr $ra

p_out: 
    li $v0, 2                   # Return 2 (out of bounds)
    lw $ra, 0($sp)              # Restore return address
    addiu $sp, $sp, 4           # Deallocate Stack Space
    jr $ra



# Function: test_fit
# Arguments: 
#   $a0 - address of piece array (5 pieces)

test_fit:
    addi $sp, $sp, -12         
    sw $ra, 0($sp)             
    sw $a0, 4($sp)              

    li $t6, 0                   # Counter = 0
    li $t8, 7                   # Maximum ship number (7)
    li $t9, 4                   # Maximum orientations (4)
    li $s7, 20                  # Total bytes = 20 (5 pieces * 4 bytes each)

check_for_invalid:
    beq $t6, $s7, next          # Counter == 20

    # Check the ship number
    sll $t5, $t6, 2             # Memory offset: counter * 4
    add $t5, $t5, $a0           # Memory address: base + offset
    lb $t7, 0($t5)              # Load ship number
    blt $t7, $0, invalid     # Ship number < 0
    bgt $t7, $t8, invalid       # Ship number > 7

    # Check the orientation
    addi $t6, $t6, 1            # Increment counter to next byte
    sll $t5, $t6, 2             # Memory offset: counter * 4
    add $t5, $t5, $a0           # Memory address: base + offset
    lb $t7, 0($t5)              # Load orientation
    blt $t7, $0, invalid     # Orientation < 0
    bgt $t7, $t9, invalid       # Orientation > 4

    addi $t6, $t6, 3            # Skip row and column
    j check_for_invalid         # Check next piece

next:
    li $t6, 0                   # Counter = 0
    li $v1, 0                   # Error code = 0
    li $a1, 1                   # Ship number = 1
    sw $a1, 8($sp)              # Save ship number to stack

placePieces:
    beq $t6, $s7, test_done     # Counter = 20

    lw $a0, 4($sp)              # Load the starting address of the piece array
    sll $t7, $t6, 2             # Offset: counter * 4
    add $a0, $a0, $t7           # Address of the current piece
    jal placePieceOnBoard       
    or $v1, $v1, $v0            # Error code

    addi $t6, $t6, 4            # Move to the next piece (4 bytes per piece)

    lw $a1, 8($sp)              # Load current ship number from stack
    addi $a1, $a1, 1            # Increment Ship number
    sw $a1, 8($sp)              # Save updated ship number back to stack

    j placePieces               # Continue placing the next piece

test_done:
    lw $ra, 0($sp)              
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    addi $sp, $sp, 12       

    move $v0, $v1               # Error code 
    jr $ra                      

invalid:
    lw $ra, 0($sp)              
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    addi $sp, $sp, 12    

    li $v0, 4                   # Return 4
    jr $ra                      





T_orientation4:
    # Study the other T orientations in skeleton.asm to understand how to write this label/subroutine
    move $a0, $s5               # row
    move $a1, $s6               # col
    move $a2, $s1
    jal place_tile              # Place center tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 1           # row + 1
    move $a1, $s6               # col
    move $a2, $s1
    jal place_tile              # Place upper tile
    or $s2, $s2, $v0

    move $a0, $s5
    addi $a0, $a0, 2            # row + 2
    move $a1, $s6               # col
    move $a2, $s1
    jal place_tile              # Place lower tile
    or $s2, $s2, $v0

    move $a0, $s5          
    move $a1, $s6     
    addi $a0, $a0, 1           # row + 1
    addi $a1, $a1, 1            # col + 1
    move $a2, $s1
    jal place_tile              # Place right tile
    or $s2, $s2, $v0

    j piece_done

.include "skeleton.asm"