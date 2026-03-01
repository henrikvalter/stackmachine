
import sys

def to_32b(n: int) -> str:
    return format(n & 0xFFFFFFFF, '032b')

def parse_instruction(instruction_list : list, tokens):
    if len(tokens) == 0:
        pass
    elif len(tokens) == 1 and tokens[0] == "nop":
        instruction_list.extend([
            f"{to_32b(0x0)} -- nop"
        ])
    elif len(tokens) == 2 and tokens[0] == "ipush":
        pushvalue = int(tokens[1])
        instruction_list.extend([
            f"{to_32b(0x1)} -- ipush {pushvalue}",
            f"{to_32b(pushvalue)}"
        ])
    elif len(tokens) == 1 and tokens[0] == "iadd":
        instruction_list.extend([
            f"{to_32b(0x2)} -- iadd",
        ])
    elif len(tokens) == 1 and tokens[0] == "iprint":
        instruction_list.extend([
            f"{to_32b(0x3)} -- iprint",
        ])
    elif len(tokens) == 2 and tokens[0] == "branch":
        target_label = tokens[1]
        instruction_list.extend([
            f"{to_32b(0x4)} -- branch to label \"{target_label}\"",
            f"__LABEL__{target_label}"
        ])
    elif len(tokens) == 1 and tokens[0] == "dup":
        instruction_list.extend([
            f"{to_32b(0x5)} -- dup"
        ])
    elif len(tokens) == 2 and tokens[0] == "branch_if_equal":
        target_label = tokens[1]
        instruction_list.extend([
            f"{to_32b(0x6)} -- branch to label \"{target_label}\" if equal",
            f"__LABEL__{target_label}"
        ])
    elif len(tokens) == 2 and tokens[0] == "branch_if_not_equal":
        target_label = tokens[1]
        instruction_list.extend([
            f"{to_32b(0x7)} -- branch to label \"{target_label}\" if not equal",
            f"__LABEL__{target_label}"
        ])
    elif len(tokens) == 2 and tokens[0] == "iload":
        address = int(tokens[1])
        instruction_list.extend([
            f"{to_32b(0x8)} -- iload {address}",
            f"{to_32b(address)}"
        ])
    elif len(tokens) == 2 and tokens[0] == "istore":
        address = int(tokens[1])
        instruction_list.extend([
            f"{to_32b(0x9)} -- istore {address}",
            f"{to_32b(address)}"
        ])
    elif len(tokens) == 1 and tokens[0] == "exit":
        instruction_list.extend([
            f"{to_32b(0xFFFFFFFF)} -- exit"
        ])
    else:
        print(f"Assembly of tokens \"{tokens}\" failed.")
        sys.exit(1)

def main():
    assert len(sys.argv) == 3
    inputfile = sys.argv[1]
    outputfile = sys.argv[2]

    with open(inputfile, "r") as f:
        lines = [line.strip() for line in f.readlines()]

    # First pass
    instruction_list = []
    label_table = dict()
    for line in lines:
        words = line.split()
        for i in range(len(words)):
            if words[i].startswith(";"):
                words = words[:i]
                break
        if len(words) == 0:
            continue
        elif words[0][-1] == ":":
            label = words[0][:-1]
            assert label not in label_table
            label_table[label] = len(instruction_list)
            parse_instruction(instruction_list, words[1:])
        else:
            parse_instruction(instruction_list, words)

    # print(label_table)
    # print(instruction_list)

    # Second pass: figure out labels

    for src_idx,instruction in enumerate(instruction_list):
        if not instruction.startswith("__LABEL__"):
            continue
        target_label = instruction[9:]
        dst_idx = label_table[target_label]
        branch_length = dst_idx - src_idx + 1
        # print(branch_length)
        instruction_list[src_idx] = f"{to_32b(branch_length)} -- branch length {branch_length}"

    # print(label_table)
    # print(instruction_list)

    with open(outputfile, "w") as f:
        f.write(f"--------------------------------------------------\n")
        f.write(f"-- Assembly of source file {inputfile}\n")
        f.write(f"--------------------------------------------------\n")
        for line in instruction_list:
            f.write(line + "\n")

if __name__ == "__main__":
    main()