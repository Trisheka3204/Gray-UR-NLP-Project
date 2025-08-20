import csv
# make a function to pull out data from <text> tags
# looking for questions : 2 - 2A, 4 - 4A, 5 - 5A, 7 - 7A

def read_data(filename):
    with open(filename, "r") as f:
        lines = f.readlines()
        newl(lines)
        text = remove_non_text(lines)
        extract_all(text)
        return text
        


def extract(string):
    start = 0
    while start < len(string) and string[start] != ">":
        start = start + 1
    start = start + 1
    end = len(string) - 7
    
    return string[start:end]

def extract_all(da):
    for i in range(len(da)):
        da[i] = extract(da[i])


def remove_non_text(data):
    ret = []
    for line in data:
        if line.startswith("<text"):
            ret.append(line)
    return ret

def newl(dat):
    for i in range(len(dat)):
        dat[i] = dat[i].rstrip()

def responses(data, search):
    for i in range(len(data)):
        if search in data[i]:
            loc = i
            break
    title = data[loc]
    res = []
    loc = loc + 4
    length = 1
    st = ""
    while not data[loc].startswith("<b>"):
        
        while not data[loc + length].startswith("•") and not data[loc + length].startswith("<b>"):
            length = length + 1

        for i in range(length):
            st = st + data[loc + i] + " "
        loc = loc + length
        res.append(st)
        length = 1
        st = ""
    return (res, title)        

def remove_dot(res):
    for i in range(len(res)):
        res[i] = res[i][2:-1]

def remove_inner_comma(line):
    return line.replace(",", "")

if __name__ == "__main__":
    q1 = []
    q2 = []
    q3 = []
    q4 = []
    for i in range(1, 9):
        filename = "1215-" + str(i)
        print(filename)
        text = read_data(filename)
        q11 = responses(text, "2 - 2A")
        q22 = responses(text, "4 - 4A")
        q33 = responses(text, "5 - 5A")
        q44 = responses(text, "7 - 7A")

        a = responses(text, "2 - 2A")[0]
        b = responses(text, "4 - 4A")[0]
        c = responses(text, "5 - 5A")[0]
        d = responses(text, "7 - 7A")[0]
        for i in a:
            q1.append(i)
        for i in b:
            q2.append(i)
        for i in c:
            q3.append(i)
        for i in d:
            q4.append(i)
    
    for i in range(9, 12):
        filename = "1215-" + str(i)
        print(filename)
        text = read_data(filename)
        q11 = responses(text, "2 - 2A")
        q22 = responses(text, "4 - 4A")
        q33 = responses(text, "5 - 5A")

        a = responses(text, "2 - 2A")[0]
        b = responses(text, "4 - 4A")[0]
        c = responses(text, "5 - 5A")[0]
        for i in a:
            q1.append(i)
        for i in b:
            q2.append(i)
        for i in c:
            q3.append(i)
    remove_dot(q1)
    remove_dot(q2)
    remove_dot(q3)
    remove_dot(q4)
    for i in range(len(q1)):
        q1[i] = remove_inner_comma(q1[i])
    for i in range(len(q2)):
        q2[i] = remove_inner_comma(q2[i])
    for i in range(len(q3)):
        q3[i] = remove_inner_comma(q3[i])
    for i in range(len(q4)):
        q4[i] = remove_inner_comma(q4[i])
    #print(q1[0])
    #print(q2[0])
    #print(q3[0])
    #print(q4[0])
    cols = [q11[1][3:-5], q22[1][3:-5], q33[1][3:-5], q44[1][3:-5]]
    #print(cols)
    data = [q1, q2, q3, q4]
    for i in range(1,5):
         
        with open("1215-q"+str(i)+".csv", "w") as f:
            f.write(cols[i-1] + "\n")
            for j in data[i-1]:
                f.write(j + "\n")
            f.close()
    
