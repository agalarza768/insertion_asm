def insercion(vector):
    i = 1
    while i < len(vector):
        j = i
        while j > 0 and vector[j-1] > vector[j]:
            aux = vector[j]
            vector[j] = vector[j-1]
            vector[j-1] = aux
            j = j-1
        i = i + 1
    print(vector)

vector = [6,5,3,1,8,7,2,4]
print(vector)
insercion(vector)