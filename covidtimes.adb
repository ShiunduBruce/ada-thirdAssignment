with Ada.Calendar, tools;

procedure CovidTimes is
   type pstr is access String;
   type pduration is access Duration;

   task type Customer(name : pstr);

   task type shop(openTime : pduration) is
      entry enter;
      entry leave;
      entry close;
   end shop;


   task body shop is
       served : Natural := 0;
       count : Natural := 0;
       shop_open : Boolean := True;
   begin
      delay openTime.all;

         shop_open := True;
         while shop_open loop
         select
            when count < 5 =>
               accept enter  do
                  count := count + 1;
                  served := served + 1;
                  delay 0.2;
               end enter;
         or
           when count > 0 =>
               accept leave  do
                  count := count - 1;
               end leave;
         or
            accept close  do
               shop_open := False;
               tools.Output.Puts("Number of customers served " & Natural'Image(served), 1);
            end close;
         end select;

         end loop;

      end shop;

      type pshop is access shop;
      ptshop : array (1..3) of pshop;

   task body Customer is
      subtype Index is Positive range 1..3;
      package Ind_Generator is new tools.Random_Generator(Index);
         shop_index : Index;
         trial : Natural := 0;
         shop_entered : Boolean := False;
      begin
         shop_index := Ind_Generator.GetRandom;
         delay 0.5;

         while trial < 2 and not shop_entered loop
            select
               ptshop(shop_index).enter;
               shop_entered := True;
               tools.Output.Puts(name.all & " has entered Shop " & Index'Image(shop_index), 1);
               delay 2.0;
            or
               delay 0.5;
            end select;
            trial := trial + 1;
         end loop;

         if not shop_entered then
            tools.Output.Puts(name.all & " Could not enter shop", 1);
         else
            tools.Output.Puts(name.all & " has left shop " & Index'Image(shop_index), 1);
            ptshop(shop_index).leave;
         end if;

         end Customer;

   type pcustomer is access Customer;
   ptcustomers : array (1..20) of pcustomer;

   use type Ada.Calendar.Time;
   closing_time : Ada.Calendar.Time := Ada.Calendar."+"( Ada.Calendar.Clock, 12.0 );
   current_time : Ada.Calendar.Time := Ada.Calendar."+"( Ada.Calendar.Clock, 0.0 );

begin
   for i in 1..3 loop
      ptshop(i) := new shop(new Duration'(0.2 * Duration(i)));
   end loop;

   while current_time <= closing_time loop
      for i in 1..20 loop
         if ptcustomers(i) = null or  else  ptcustomers(i)'Terminated then
            ptcustomers(i) := new Customer(new String'("Cus1-" & Integer'Image(i) ) );
            delay 0.1;
         end if;
      end loop;
      current_time := Ada.Calendar."+"( Ada.Calendar.Clock, 0.0 );
   end loop;
   delay 4.0; --give the last customers time to leave
   tools.Output.Puts("",1);
   for i in 1..3 loop
      tools.Output.Puts("Shop " & Integer'Image(i) & " ");
      ptshop(i).close;
   end loop;
end CovidTimes;
