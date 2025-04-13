import sys
import csv
from dataclasses import dataclass

filename = "ecs.csv"
outstr = ""
outFor = "odin"
outfile = "comps_gen.odin"

@dataclass
class ComponentType:
    name: str
    type: str

@dataclass
class Component:
    name: str
    components: list[ComponentType]


@dataclass
class EntityComponentType:
    name: str
    type: str


@dataclass
class Entity:
    name: str
    components: list[EntityComponentType]

components = []
entities = []

def addTabs(amount):
    global outstr
    for x in range(amount):
        outstr += " "


def printHeader():
    global outstr
    outstr += "package game\n\n"

    outstr += "vec3 :: [3]f32\n"
    outstr += "vec4 :: [4]f32\n"
    outstr += "quat :: quaternion128\n\n"

def printEnums():
    global outstr

    outstr += "EntityTypes :: enum\n{\n"
    for ent in entities:
        addTabs(4)
        outstr += ent.name + "Type,\n"

    outstr += "}\n\n"

def printComponentOdin(component: Component):
    global outstr
    outstr += component.name + "Component" + " :: struct\n{\n"
    for cType in component.components:
        addTabs(4)
        outstr += cType.name + " : " + cType.type + ",\n"
    outstr += "}\n\n"

def printComponents():
    global components
    for comp in components:
        printComponentOdin(comp)


def printEntityOdin(entity: Entity):
    global outstr
    outstr += entity.name + "Entity" + " :: struct\n{\n"
    for cType in entity.components:
        addTabs(4)
        outstr += cType.name + " : [dynamic] " + cType.type + "Component,\n"
    outstr += "}\n\n"

def printEntities():
    global entities
    for ent in entities:
        printEntityOdin(ent)



def parseComponents(csvreader):
    global components

    found = False
    component = Component(name = "", components = [])
    for row in csvreader:
        if(found == False and len(row) == 1 and row[0] == "Components:"):
            found = True
            continue
        if(found == False):
            continue
        if(len(row) == 1 and row[0] == "end"):
            return
        if(len(row) == 0):
            if(len(component.name) > 0):
                components.append(component)
            component = Component(name = "", components = [])
        elif(len(row) == 1):
            if(len(component.name) == 0):
                component.name = row[0]
            else:
                print("Error, component already has a name!")
        elif(len(row) == 2):
            componentType = ComponentType( name = row[0], type = row[1])
            component.components.append(componentType)



def parseEntities(csvreader):
    global entities
    found = False
    entity = Entity(name = "", components = [])
    for row in csvreader:
        if(found == False and len(row) == 1 and row[0] == "Entities:"):
            found = True
            continue
        if(found == False):
            continue
        if(len(row) == 1 and row[0] == "end"):
            return
        if(len(row) == 0):
            if(len(entity.name) > 0):
                entities.append(entity)
            entity = Entity(name = "", components = [])
        elif(len(row) == 1):
            if(len(entity.name) == 0):
                entity.name = row[0]
            else:
                print("Error, entity already has a name:", entity.name)
        elif(len(row) == 2):
            component = EntityComponentType( name = row[0], type = row[1])
            entity.components.append(component)


def main():
    with open(filename, newline='') as csvfile:
        component = Component("", [])
        csvreader = csv.reader(csvfile, delimiter=',', quotechar='|')
        parseComponents(csvreader)
        parseEntities(csvreader)

    printHeader()
    printEnums()
    printComponents()
    printEntities()

    print(outstr)
    with open(outfile, "w") as f:
        f.write(outstr)

if __name__ == "__main__":
    main()
