#include<vector>
#include "hashtable.h"

using namespace std;

class sym_table{
    private:
      vector<hashtable_t*> s;
      int scope;

    public:

      void new_scope(){
        hashtable_t* ht = ht_create(50);
        s.push_back(ht);
        scope++;
      }

      void close_scope(){
        if(s.size() > 0){
          s.pop_back();
          scope--;
        }
      }

      sym_table(){
        new_scope(); //for global scope
      }

      value_s* find_id(char* key){
        vector<hashtable_t*>::iterator it;
        value_s* get_info;
        hashtable_t* ht;

        for(it = s.end() - 1; it >= s.begin(); it--){
          ht = *it;
          get_info = ht_get(ht, key);

          if(get_info != NULL)
            break;
        }

        return get_info;
      }

      int save_id(char* key, value_s* value){
        // printf("Received %s. Current status - \n", key);
        // display();
        // printf("%d", s.size());
        hashtable_t* ht = s[s.size()-1];
        // printf("Hashtable : %p\n", ht);
        // printf("%d %d\n",(int)value->token, (int)value->type);
        if( ht_get(ht, key) == NULL){
           ht_set(ht, key, value);
           return 1; //new id was stored
        }
        return 0; //id exists already
        // printf("Stored!\n");
      }

      void update_id(char* key, value_s* value){
        hashtable_t* ht = s[s.size()-1];
        ht_set(ht, key, value);
        // printf("Updated %s", key);
      }

      void display(){
        for(vector<hashtable_t*>::iterator it = s.begin(); it != s.end(); it++){
          display_table(*it);
        }
      }
};
