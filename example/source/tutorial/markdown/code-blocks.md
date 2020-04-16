# Code blocks

Please find below a sample of a `C++` code:

```c++
namespace example
{
    class MyAwesomeClass
    {
        public:
            MyAwesomeClass();
            ~MyAwesomeClass();
    }
}
```

An extract of a `java` code can be found [below](#myjavacode):

```{#myjavacode .java .numberLines startFrom="0"}
public class Fibonacci {
    public static void main(String[] args) {
        int n = 10, t1 = 0, t2 = 1;
        System.out.print("First " + n + " terms: ");
        for (int i = 1; i <= n; ++i)
        {
            System.out.print(t1 + " + ");
            int sum = t1 + t2;
            t1 = t2;
            t2 = sum;
        }
    }
}
```

The following code block owns a long line:

```{.numberLines startFrom="100"}
This is a very long long long long long long long long long long long long long long long long long long long line which cuts the page without fix.
```
