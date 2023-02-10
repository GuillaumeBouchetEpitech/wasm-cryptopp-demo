

#include "aes-cbc-filter.hpp"

#include <iostream>

#include <string>
#include <string_view>

#include <cstdlib>
// std::exit

#include "osrng.h"
// CryptoPP::AutoSeededRandomPool

#include "cryptlib.h"
// CryptoPP::Exception;

#include "hex.h"
// CryptoPP::HexEncoder

#include "filters.h"
// CryptoPP::StringSink
// CryptoPP::StringSource
// CryptoPP::StreamTransformationFilter

#include "aes.h"
// CryptoPP::AES

#include "ccm.h"
// CryptoPP::CBC_Mode;

// #include "assert.h"

namespace {

	std::string _asHexString(const uint8_t* inData, int inSize)
	{
		std::string value;
		CryptoPP::StringSource(inData, inSize, true,
			new CryptoPP::HexEncoder(
				new CryptoPP::StringSink(value)
			) // CryptoPP::HexEncoder
		); // StringSource
		return value;
	}

	std::string _asHexString(const std::string& inStr)
	{
		return _asHexString(reinterpret_cast<const uint8_t*>(inStr.data()), int(inStr.size()));
	}

}

// int main(int argc, char* argv[])
int runAesTest()
{
	try {
		CryptoPP::AutoSeededRandomPool prng(true);

		// byte key[AES::DEFAULT_KEYLENGTH];
		unsigned char key[CryptoPP::AES::DEFAULT_KEYLENGTH];
		prng.GenerateBlock(key, sizeof(key));

		// byte iv[AES::BLOCKSIZE];
		unsigned char iv[CryptoPP::AES::BLOCKSIZE];
		prng.GenerateBlock(iv, sizeof(iv));

		std::string plain = "plain text payload (CBC Mode Test)";
		std::string encoded;
		std::string recovered;

		/*********************************\
		\*********************************/

		// Pretty print key
		std::cout << "-> key: \"" << _asHexString(key, sizeof(key)) << "\"" << std::endl;

		// Pretty print iv
		std::cout << "-> iv:  \"" << _asHexString(iv, sizeof(iv)) << "\"" << std::endl;

		/*********************************\
		\*********************************/

		try
		{
			std::cout << " ===> plain text:     \"" << plain << "\"" << std::endl;

			CryptoPP::CBC_Mode<CryptoPP::AES>::Encryption e;
			e.SetKeyWithIV(key, sizeof(key), iv);

			// The StreamTransformationFilter removes
			//  padding as required.
			CryptoPP::StringSource source(plain, true,
				new CryptoPP::StreamTransformationFilter(e,
					new CryptoPP::StringSink(encoded)
				) // StreamTransformationFilter
			); // StringSource

	#if 0
			CryptoPP::StreamTransformationFilter filter(e);
			filter.Put((const byte*)plain.data(), plain.size());
			filter.MessageEnd();

			const size_t ret = filter.MaxRetrievable();
			encoded.resize(ret);
			filter.Get((byte*)encoded.data(), encoded.size());
	#endif
		}
		catch(const CryptoPP::Exception& e)
		{
			std::cerr << e.what() << std::endl;
			std::exit(1);
		}

		/*********************************\
		\*********************************/

		// Pretty print encoded
		std::cout << " ===> encoded text:   \"" << _asHexString(encoded) << "\"" << std::endl;

		/*********************************\
		\*********************************/

		try
		{
			CryptoPP::CBC_Mode<CryptoPP::AES>::Decryption d;
			d.SetKeyWithIV(key, sizeof(key), iv);

			// The StreamTransformationFilter removes
			//  padding as required.
			CryptoPP::StringSource s(encoded, true,
				new CryptoPP::StreamTransformationFilter(d,
					new CryptoPP::StringSink(recovered)
				) // StreamTransformationFilter
			); // StringSource

#if 0
			CryptoPP::StreamTransformationFilter filter(d);
			filter.Put((const byte*)encoded.data(), encoded.size());
			filter.MessageEnd();

			const size_t ret = filter.MaxRetrievable();
			recovered.resize(ret);
			filter.Get((byte*)recovered.data(), recovered.size());
#endif

			std::cout << " ===> recovered text: \"" << recovered << "\"" << std::endl;
		}
		catch(const CryptoPP::Exception& e)
		{
			std::cerr << e.what() << std::endl;
			std::exit(1);
		}

		/*********************************\
		\*********************************/

	}
	catch(const CryptoPP::Exception& e)
	{
		std::cerr << e.what() << std::endl;
		return -2;
	}
	catch(const std::exception& e)
	{
		std::cerr << e.what() << std::endl;
		return -1;
	}

	return 0;
}

