package main

import (
        "fmt"
        "os/exec"
        "strings"
        "encoding/json"
        "log"
)

const (
        MAX_OS_PACKAGES = 1500
)

type OSPackage struct {
    Name   string    `json:"name"`
    Version string   `json:"version"`
    License string   `json:"license"`
    Url     string   `json:"url"`
}

type BOM struct {
    Project_name    string       `json:"bds_hub_project"`
    Project_release string       `json:"bds_hub_project_release"`
    Components      *[MAX_OS_PACKAGES]*OSPackage  `json:"ossComponentsToMatch"`
}

func getPackages() *[MAX_OS_PACKAGES]*OSPackage {
   cmd  := "dpkg -l | grep \"ii\" |  awk '{print $2 \",\" $3;}'"
   out, err := exec.Command("bash", "-c", cmd).Output()
   if err != nil {
       fmt.Sprintf("Failed to execute command: %s", cmd)
       return nil
   }
   lines := strings.Split(string(out), "\n")
   var OSPackages [MAX_OS_PACKAGES]*OSPackage
   for i, line := range lines {
       /* line =strings.TrimSuffix(line, "\n") */
       fmt.Printf(line)
       pckg := strings.Split(string(line), ",")
       if len(pckg) == 2  {
           /* fmt.Printf("name : %s ; version : %s\n", pckg[0], pckg[1]) */
           p := new(OSPackage)
           p.Name = pckg[0]
           p.Version = pckg[1]
           OSPackages[i] = p
       }
   }
   return  &OSPackages
}

func main() {
   
   OSpckgs := getPackages()
   bom := new(BOM)
   bom.Project_name = "image name"
   bom.Project_release = "release"
   bom.Components = OSpckgs
   jsonBom, _:=json.Marshal(*bom)
   for i, pckg := range *OSpckgs {
       if pckg == nil {
         fmt.Printf("number of elements : %d \n", i)
         break
       }
       /* create the json message */
       test := &pckg
       prr,err := json.Marshal(test)
       if err != nil {
          log.Fatal(err)
       }
       fmt.Println(string(prr))       
       fmt.Printf("name : %s ; version : %s\n", pckg.Name, pckg.Version)
   }
   fmt.Println(string(jsonBom))
   jan,_:=json.Marshal(OSpckgs)
   fmt.Printf(string(jan)) 

}
