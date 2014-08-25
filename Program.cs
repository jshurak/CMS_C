using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CMS_C
{
    class Program
    {
        static void Main(string[] args)
        {
            string Name = Console.ReadLine();
            Instance instance = new Instance(Name);
            if(instance.TestConnection())
            {
                Console.WriteLine("Connection to " + instance.instanceName + " was successful.");
            }
            else
            {
                Console.WriteLine("Connection to " + instance.instanceName + " was false.");
            }
            instance.CheckServices();

            Console.ReadLine();


        }
    }
}
