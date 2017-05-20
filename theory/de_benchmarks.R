library(ggplot2)
library(gridExtra)
# define parameters
a = 31;
b = 0.4;
c = 2;
Ni = 5;
No = 3;
n = Ni + No; 
e = 12;
alpha = 1/3;
beta = seq(0,1,0.01)
t = 88.8

# data frame to collect benchmarks
benchmarks <- data.frame("deterrence" = beta)

# Cooperation ==== 
insiders_coop <- function(x){
  (a - c) / (b * Ni) *
    (
      ((No + 1) - No*(1 - x)*(1 - alpha*x)) 
        / 
      (2 * (No + 1) - No*(1 - x)*(1 - alpha*x))
    )
}
outsiders_coop <- function(x){
  (a - c) / (b * No) *
    (
      No*(1-x)
        / 
      (2 * (No + 1) - No*(1 - x)*(1 - alpha*x))
    )
}

# calculate harvests
benchmarks$in_c <- apply(benchmarks[1], 1, insiders_coop)
benchmarks$out_c <- apply(benchmarks[1], 1, outsiders_coop)
# impose constraints
benchmarks$out_c <- with(benchmarks, ifelse(out_c > e, e, out_c))
benchmarks$in_c <- with(benchmarks, ifelse(out_c == e, 3.65, in_c))

# Noncooperation ====
insiders_NONcoop <- function(x){
  (a - c) / (b*Ni) *
    (
      (Ni*(No+1) - No*(1-x)*(Ni - alpha*x)) 
      / 
        ((Ni+1)*(No+1) - No*(1-x)*(Ni - alpha*x))
    )
}
outsiders_NONcoop <- function(x){
  (a - c) / (b*No) *
    (
      (No*(1-x)) 
      / 
        ((Ni+1)*(No+1) - No*(1-x)*(Ni - alpha*x))
    )
}
# calculate harvests
benchmarks$in_nc <- apply(benchmarks[1], 1, insiders_NONcoop)
benchmarks$out_nc <- apply(benchmarks[1], 1, outsiders_NONcoop)

# Payoffs ====

payoff_in <- function(x,y,z) {
  t + c*(e - x) + 
    x*(a - b*((Ni*x) + (No*y))) - 
      ( (alpha*z*(a - c - b*(Ni*x))*(No*y)) / Ni)
}
payoff_out <- function(y,x) t + c*(e - y) + y*(a - b*((Ni*x) + (No*y)))

## cooperation
benchmarks$pi_in_c <- payoff_in(benchmarks$in_c, benchmarks$out_c, benchmarks$deterrence)
benchmarks$pi_out_c <- payoff_out(benchmarks$out_c, benchmarks$in_c)

## noncooperation
benchmarks$pi_in_nc <- payoff_in(benchmarks$in_nc, benchmarks$out_nc, benchmarks$deterrence)
benchmarks$pi_out_nc <- payoff_out(benchmarks$out_nc, benchmarks$in_nc)

# Visual ====

## harvest as a function of beta
# insiders
p.harvest.in <- ggplot(benchmarks, aes(x=deterrence, y=in_c)) + 
  geom_point(color="green") + 
  # noncoop
  geom_point(data = benchmarks, aes(x=deterrence,y=in_nc), color="green", shape=1) +
  xlab("deterrence (beta)") + ylab("individual insider harvest") 
# outsiders
p.harvest.out <- ggplot(benchmarks, aes(x=deterrence, y=out_c)) + 
  geom_point(color="blue") + 
  # noncoop
  geom_point(data = benchmarks, aes(x=deterrence,y=out_nc), color="blue", shape=1) +
  xlab("deterrence (beta)") + ylab("individual outsider harvest") 
# joint plot
grid.arrange(p.harvest.in, p.harvest.out, ncol=2)



## payoff as a function of beta

p.payoff.in <- ggplot(benchmarks, aes(x=deterrence, y=pi_in_c)) + 
  geom_line(color="green", size=1.25) + 
  # noncoop
  geom_line(data = benchmarks, aes(x=deterrence,y=pi_in_nc), color="green", linetype="dashed", size=1.25) +
  xlab("deterrence (beta)") + ylab("individual insider payoff") 


p.payoff.out <- ggplot(benchmarks, aes(x=deterrence, y=pi_out_c)) + 
  geom_line(color="blue", size=1.25) + 
  # noncoop
  geom_line(data = benchmarks, aes(x=deterrence,y=pi_out_nc), color="blue", linetype="dashed", size=1.25) +
  xlab("deterrence (beta)") + ylab("individual outsider payoff") 



## Joint plot
grid.arrange(p.harvest.in, p.payoff.in, p.harvest.out, p.payoff.out, ncol=2)
