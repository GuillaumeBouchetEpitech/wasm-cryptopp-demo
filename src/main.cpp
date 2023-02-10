


#include "dh-agree.hpp"
#include "aes-cbc-filter.hpp"

#include <iostream>



#if defined __EMSCRIPTEN__
#include <emscripten/emscripten.h> // <= EMSCRIPTEN_KEEPALIVE
#endif



#if not defined __EMSCRIPTEN__


// int main(int argc, char** argv)
int main()
{

  std::cout << "#" << std::endl;
  std::cout << "#" << std::endl;
  std::cout << "#" << std::endl;

  {
    const int result = runAesTest();
    if (result != 0)
      return result;
  }

  std::cout << "#" << std::endl;
  std::cout << "#" << std::endl;
  std::cout << "#" << std::endl;

  {
    const int result = run_dh_agree();
    if (result != 0)
      return result;
  }

  std::cout << "#" << std::endl;
  std::cout << "#" << std::endl;
  std::cout << "#" << std::endl;


	return 0;
}


#else


extern "C" {

EMSCRIPTEN_KEEPALIVE
void
runDhLogic()
{
  run_dh_agree();
}


EMSCRIPTEN_KEEPALIVE
void
runAesLogic()
{
  runAesTest();
}



EMSCRIPTEN_KEEPALIVE
void
makeWasmPrintMessage(const char* inMessage)
{
  std::cout << "JS text printed in the wasm code: \"" << inMessage << "\"" << std::endl;
}


EMSCRIPTEN_KEEPALIVE
char*
getHeapString()
{
  constexpr std::string_view k_message = "Hello from the wasm heap!";
  char* pMessage = new char[k_message.size()];
  std::memcpy(pMessage, k_message.data(), k_message.size());
  return pMessage;
}


}

#endif
